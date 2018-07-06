#
# Author: Rasmus Johansson
# Level: Novice
# 
#
#
#
#

# The TV-Shows it's monitoring
[array]$Script:seriesNeeded = "*Marvels*Agent*of*S*H*I*E*L*D"


function GetSeriesOnWebsite {
    $script:seriesMagnets = New-Object System.Collections.ArrayList
    [array]$Script:seriesWebsite = $null
    [array]$Script:seriesMagnets = $null

    
    $uri = "https://thepiratebay.org/top/205" # URL to the source of download
    $HTML = Invoke-WebRequest -Uri $uri
        foreach ($sNeeded in $seriesNeeded){
        #[array]$name = $HTML.Links | Where-Object -Property innerHTML -Like "*$sNeeded*[ettv]*" #| select innerHTML -ExpandProperty innerHTML 
        [array]$name = $HTML.Links | ?{$_.innerHTML -Like "*$sNeeded*[ettv]*"} #| select innerHTML -ExpandProperty innerHTML 
        #[array]$magnet = $HTML.Links | Where-Object -Property href -Like "magnet*$sNeeded*" #| select href -ExpandProperty href
        [array]$magnet = $HTML.Links | ?{$_.href -Like "magnet*$sNeeded*"} #| select href -ExpandProperty href
        #$HTML.Links | ? -Property href -Like "magnet*$sNeeded*"
        [array]$Script:seriesWebsite += $name
        [array]$Script:seriesMagnets += $magnet

        }
            
}

#$test3 = (Invoke-WebRequest -Uri $uri).links | Where-Object -Property innerHTML -Like "*[ettv]*" | Rename-Item -NewName {$_.innerHTML -replace [regex]::Escape("["),"(" -replace [regex]::Escape("]"),")"}
#$test2 =  Rename-Item -NewName {$test.Links.innerText -replace '[','(' -replace ']',')'}  #-replace [regex]::Escape("["),"(" -replace [regex]::Escape("]"),")"}
            

function GetSeriesOnDisk {
$Script:seriesDisk = $null

$location = "D:\Series"
    [array]$serie = Get-ChildItem -Path $location -Recurse

    [array]$Script:seriesDisk =  $serie
}

function MatchSeriesOnDiskWithWebsite {
    $contentLoc = "D:\Downloads\Downloaded\SkipDownload.txt"
    [array]$Script:Matched = $null
    Clear-Content -Path $contentLoc

    [array]$series = $seriesWebsite.innerHTML
    [array]$location = (Get-ChildItem -Path "D:\Series" -Recurse | ?{$_.PSIsContainer}).FullName
    
        foreach($serie in $series){
            foreach($loc in $location){
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

    foreach($magnet in $seriesMagnets.href){
        if(!($magnet -like "*$cleanContent*")){
            
            start $magnet
            Write-Host "Starting download "
        
        }else{

        Write-Host "Error... "
        }
    }

}

function MoveDownloadedMaterial {
    $source = Get-ChildItem -Path "D:\Downloads\Downloaded" | select name -ExpandProperty name
    $destination = Get-ChildItem -Path "D:\Series" -Recurse | ?{$_.PSIsContainer} | select name -ExpandProperty name 
    $pathSource = (Get-ChildItem -Path "D:\Downloads\Downloaded" | ?{$_.PSIsContainer}).FullName
    pathDest = (Get-ChildItem -Path "D:\Series" | ?{$_.PSIsContainer}).FullName

        foreach($folder in $source){
            if($destination -contains $folder){
                Remove-Item $folder -Recurse -Force
            }else{
            Write-Host "hej"
            }

        }

}


function test {

    foreach($seriesWeb in $seriesWebsite){
        if($seriesWeb -match $seriesMagnets){
        Write-Host $seriesMagnets
        }
    }

}


function TESTMoveDownloadedMaterial {
    $source = Get-ChildItem -Path "D:\Downloads\Downloaded" #| select name -ExpandProperty name
    $destination = Get-ChildItem -Path "D:\Scripts\Test" -Recurse #| ?{$_.PSIsContainer} | select name -ExpandProperty name 
    #$pathSource = (Get-ChildItem -Path "D:\Downloads\Downloaded" | ?{$_.PSIsContainer}).FullName
    #$pathDest = (Get-ChildItem -Path "D:\Series" | ?{$_.PSIsContainer}).FullName
    $folder = "Arrow.S05E21.WEB-DL.x264-FUM[ettv]"
    $path = "D:\Downloads\Downloaded\Arrow.S05E21.WEB-DL.x264-FUM``[ettv``]"
    $path2 = "D:\Series\Arrow\Season 5"
    $path3 = "D:\Downloads\Downloaded\"

        foreach($folder in $source.name){       
            #foreach ($folder2 in){}


            if($destination -contains $folder){
                #Remove-Item $path -Recurse -Force
                Write-Host "Removed.."

            }else{
                Set-Location $path3
                #Move-Item $folder $path2
                "Moving.."
            }

        }

}

#$path = "D:\Scripts\Test\ArrowS01"
#$path2 = "D:\Scripts\Test\Arrow"

#Move-Item "$path" "$path2"
#Move-Item D:\Scripts\Test\Arrow\S05 'D:Downloads\Downloaded\Arrow.S05E21.WEB-DL.x264-FUM`[ettv`]' 



function TESTMatchSeriesOnDiskWithWebsite {
    [array]$Script:Matched = $null

        foreach($Website in $seriesWebsite.innerHTML){
            [array]$Script:Matched += $seriesDisk | ?{$_.name -Like $Website}
            
        }


}


<#
function changeSigns{
    #Byter ut alla "[" mot "(" och "]" mot ")" i Get-childitem pathen.
    Get-ChildItem -Path "D:\Series" -Recurse | Rename-Item -NewName {$_.name -replace [regex]::Escape("("),"[" -replace [regex]::Escape(")"),"]"} -ErrorAction SilentlyContinue
}
#>
#start $seriesMagnets.href[3]

#$seriesWebsite.innerHTML | Rename-Item -NewName {$_ -replace [regex]::Escape("["),"(" -replace [regex]::Escape("]"),")"} -ErrorAction SilentlyContinue

<#
$seriesWebsite = "Arrow.S05E23.HDTV.x264-SVA[ettv]",
"Arrow.S05E21.WEB-DL.x264-FUM[ettv]",
"The.Flash.2014.S03E23.PROPER.HDTV.x264-KILLERS[ettv]",
"The.Flash.2014.S03E22.WEB-DL.x264-FUM[ettv]",
"The.Flash.2014.S03E21.WEB-DL.x264-FUM[ettv]",
"The.Flash.2014.S03E19.WEB-DL.x264-FUM[ettv]",
"The.Flash.2014.S03E18.HDTV.x264-LOL[ettv]",
"The.Flash.2014.S03E20.WEB-DL.x264-FUM[ettv]",
"The.Flash.2014.S03E17.HDTV.x264-LOL[ettv]",
"The.Big.Bang.Theory.S10E24.WEB-DL.x264-FUM[ettv]",
"The.Big.Bang.Theory.S10E22.WEB-DL.x264-FUM[ettv]",
"The.Big.Bang.Theory.S10E21.HDTV.x264-KILLERS[ettv]",
"The.Big.Bang.Theory.S10E20.HDTV.x264-LOL[ettv]",
"The.Big.Bang.Theory.S10E19.HDTV.x264-LOL[ettv]",
"The.Big.Bang.Theory.S10E18.HDTV.x264-LOL[ettv]",
"The.Big.Bang.Theory.S10E17.HDTV.x264-LOL[ettv]"
#>