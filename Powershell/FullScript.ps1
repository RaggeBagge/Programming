#
# Author: Rasmus Johansson
# Level: Novice
# 
#
#
#
#

$scriptPath = "D:\Scripts"

function Get-SeriesOnWebsite {

    [array]$seriesNeeded = Import-Csv -Path "$scriptPath\CSV\SeriesNeeded.csv"

    $script:seriesMagnets = New-Object System.Collections.ArrayList
    [array]$Script:seriesWebsite = $null
    [array]$Script:seriesMagnets = $null
    
    $uri = "https://thepiratebay.org/top/205" # URL to the source of download
    $HTML = Invoke-WebRequest -Uri $uri

        foreach ($sNeeded in $seriesNeeded.Series){
            [array]$name = $HTML.Links | ?{$_.innerHTML -like "*$sNeeded*[ettv]*"} | select innerHTML -ExpandProperty innerHTML 
            [array]$magnet = $HTML.Links | ?{$_.href -Like "magnet*$sNeeded*"} | select href -ExpandProperty href

            [array]$Script:seriesWebsite += $name
            [array]$Script:seriesMagnets += $magnet

        }

}



function Get-WholeSeriesOnWebsite {

    [array]$seriesNeeded = Import-Csv -Path "$scriptPath\CSV\SeriesNeeded.csv"

    $script:seriesMagnets = New-Object System.Collections.ArrayList
    [array]$Script:WholeSeriesWebsite = $null
    [array]$Script:WholeSeriesMagnets = $null
    $pages = 0

    do{
        $pages++
        $uri = "https://thepiratebay.org/user/ettv/$pages/7" # URL to the source of download
        $HTML = Invoke-WebRequest -Uri $uri  
        
    
        if($HTML.StatusCode -eq 200){
            foreach ($sNeeded in $seriesNeeded){       
                [array]$name = $HTML.Links | ?{$_.innerHTML -like "*$sNeeded*[ettv]*"}
                [array]$magnet = $HTML.Links | ?{$_.href -like "magnet*$sNeeded*"}
                [array]$Script:WholeSeriesWebsite += $name
                [array]$Script:WholeSeriesMagnets += $magnet
                $name.innerHTML
            }
        }else{
            Write-Host "Failed to Invoke-Webrequest.. Something went wrong.."
            Write-Host $HTML.statusCode
        }
    }while($pages -le 5)

}


function UpdateSeriesToSkip {
#DOES NOT WORK YET

    $dirSeriesToSkip = "$scriptPath\CSV\SeriesToSkip.csv"
    $SeriesToSkip =  Import-Csv "$scriptPath\CSV\SeriesToSkip.csv"
    [array]$dir = Get-ChildItem -Path "D:\Series" -Recurse -dir
    $dirStage2 = $dir.name
    $dirStage3 = $test.replace("[ettv]","")

    foreach($map in $dirStage3){  
        if(!($SeriesToSkip.SeriesToSkip.Contains($map))){
            Add-Content -Value $map -Path $dirSeriesToSkip        
        }    
    }
}


function MatchSeriesOnDiskWithWebsite { 
# Matchar serier som finns lokalt på disken med vad som finns att laddas hem 
# från hemsidan och skapar upp ett dokument med serierna som inte ska laddas hem

    $SeriesToSkip =  Import-Csv "$scriptPath\CSV\SeriesToSkip.csv"
    $dirSeriesToSkip = "$scriptPath\CSV\SeriesToSkip.csv"
    [array]$Script:Matched = $null

    [array]$series = $seriesWebsite.replace("[ettv]","")
    [array]$location = (Get-ChildItem -Path "D:\Series" -Recurse | ?{$_.PSIsContainer}).FullName
    
        foreach($loc in $location){
            foreach($serie in $series){
                if(test-path -LiteralPath "$loc\$serie"){
                    Write-Host "This path already exists $loc\$serie"
                        if(!($SeriesToSkip.SeriesToSkip.Contains($serie))){                             
                            Add-Content -Path $dirSeriesToSkip -Value $RemovedETTV                        
                        }                                                                                      
                }               
            }
        }

    [array]$SeriesToSkipAfterUpdate =  Import-Csv "$scriptPath\CSV\SeriesToSkip.csv"
    $Script:AlreadyDownloaded = $SeriesToSkipAfterUpdate.SeriesToSkip  
}



function DownloadMagnets {
# Laddar hem alla serier som finns i $seriesMagnets som inte matchar $AlreadyDownloaded

    $shouldexit = $false
    $matchedseries = $null
    foreach($magnet in $seriesMagnets.href){
        foreach($row in $AlreadyDownloaded){
            if($magnet -contains "*$row*" ){
                $shouldexit = $true
                $matchedseries = $row
            }
        }
        if($shouldexit){            
            $shouldexit = $false
            Write-Host "Found matching series, $row"           
        }
        else{            
            Write-Host "Downloading"
            start $magnet
        }
        $matchedseries = $null
       
    } 

}