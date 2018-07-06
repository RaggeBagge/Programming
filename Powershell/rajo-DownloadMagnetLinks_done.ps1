#
# Author: Rasmus Johansson
# Level: Novice
# 
#
#
#
#

# The TV-Shows it's monitoring
[array]$Script:seriesNeeded = "*Arrow*","The*Flash","*Marvels*Agent*of*S*H*I*E*L*D","The*Big*Bang*Theory*","*NCIS*Los*Angeles*"


function GetSeriesOnWebsite {
    $script:seriesMagnets = New-Object System.Collections.ArrayList
    [array]$Script:seriesWebsite = $null
    [array]$Script:seriesMagnets = $null

    
    $uri = "https://thepiratebay.org/top/205" # URL to the source of download
    $HTML = Invoke-WebRequest -Uri $uri
        foreach ($sNeeded in $seriesNeeded){
            [array]$name = $HTML.Links | ?{$_.innerHTML -Like "*$sNeeded*[ettv]*"}
            [array]$magnet = $HTML.Links | ?{$_.href -Like "magnet*$sNeeded*"} 
            [array]$Script:seriesWebsite += $name
            [array]$Script:seriesMagnets += $magnet

        }
            
}         

function MatchSeriesOnDiskWithWebsite {
    $contentLoc = "D:\Downloads\Temp\SkipDownload.txt"
    [array]$Script:Matched = $null
    Clear-Content -Path $contentLoc

    [array]$series = $seriesWebsite.innerHTML
    [array]$location = (Get-ChildItem -Path "D:\Series" -Recurse | ?{$_.PSIsContainer}).FullName
    
        foreach($loc in $location){
            foreach($serie in $series){
                if(test-path -LiteralPath "$loc\$serie"){
                    Write-Host "This path already exists $loc\$serie"
                    if(!((Get-Content -Path $contentLoc) -contains $serie)){
                            Add-Content -Path $contentLoc -Value $serie                        
                    }                                                                                      
                }               
            }
        }

    $Content = Get-Content -Path $contentLoc #Names the series that should not be downloaded
    $Script:cleanContent = $Content.replace("[ettv]","") #Removes "[ettv]" from $content
    Set-Content -Path $contentLoc -Value $cleanContent #Set the new names in the file.
           
}

function DownloadMagnets {

    $shouldexit = $false
    $matchedseries = $null
    foreach($magnet in $seriesMagnets.href){
        foreach($row in $cleanContent){
            if($magnet -like "*$row*" ){
                $shouldexit = $true
                $matchedseries = $row
            }
        }
        if($shouldexit){
            echo "Breaking -- $matchedseries"
            $shouldexit = $false           
        }
        else{            
            echo "Download Magnet -- $matchedseries"
            start $magnet
        }
        $matchedseries = $null
       
    } 

}

function MoveDownloadedMaterial {
    $source = $null
    $pathDest = $null

    $source = Get-ChildItem -Path "D:\Downloads\Downloaded" 
    $pathDest = (Get-ChildItem -Path "D:\Series" | ?{$_.PSIsContainer}).FullName    
    $loc = "D:\Series"
    $sourceLoc = "D:\Downloads\Downloaded"

        $shouldexit = $false
        $shouldexit2 = $false
        foreach($folder in $source.name){  
                       
                if($folder -match '.+?(?=.S..E..)'){
                    echo "Working with $folder"
                    $match = $matches | select values -ExpandProperty values                          
                }
                    foreach($path in $pathDest){
                        if($path -like "D:\Scripts\Test\$match"){
                            $shouldexit = $true
                        }
                   }
                   if($shouldexit){
                        echo "breaking --"
                        $shouldexit = $false
                   }else{
                        if(!(Test-Path $loc\$match)){
                            echo "making directory $match"
                            Set-Location $loc
                            mkdir $match
                        }
                   }
                if($folder -match '[S][0123456789][0123456789]'){
                
                foreach($path2 in "$pathDest\$folder"){

                   $match2 = $matches | select values -ExpandProperty values
                   echo "------- Working $folder ------ $match2"
                   $shouldexit2 = $true
                   }
                }
                    if($shouldexit2){
                    if(!(Test-Path $loc\$match\$match2)){
                            echo "making directory $match\$match2"
                            Set-Location $loc\$match
                            mkdir $match2                        
                   }else{
                        echo "Season directory already exists.. skipping this part.."
                        $shouldexit2 = $false
                        }       
            }
            if(Test-Path "$loc\$match\$match2"){
                Set-Location $sourceLoc
                Move-Item -LiteralPath "$sourceLoc\$folder" -Destination "$loc\$match\$match2\" -Force                
                echo "Moving -- $sourceLoc\$folder -- to -- $loc\$match\$match2\ --"  
            }                   
        }
}

function changeSigns{
    #Byter ut alla "[" mot "(" och "]" mot ")" i Get-childitem pathen.
    Get-ChildItem -Path "D:\Series" -Recurse | Rename-Item -NewName {$_.name -replace [regex]::Escape("("),"[" -replace [regex]::Escape(")"),"]"} -ErrorAction SilentlyContinue
}

<#

Write-Host "Starting script.." -ForegroundColor Green
Write-Host "Starting fetching new series from website.." -ForegroundColor Green

    GetSeriesOnWebsite

sleep -Seconds 10
cls
Write-Host "Starting matching local library with website.." -ForegroundColor Green

    MatchSeriesOnDiskWithWebsite

sleep -Seconds 10
cls
Write-Host "Starting downloading.." -ForegroundColor Green

    DownloadMagnets

sleep -Seconds 300
cls
Write-Host "Starting moving to the correct structure.." -ForegroundColor Green

    MoveDownloadedMaterial

Write-Host "All done here.." -ForegroundColor Green


#>