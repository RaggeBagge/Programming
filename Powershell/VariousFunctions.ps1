# Author: Rasmus Johansson
# Various functions with diffirent purposes
#
#




function Restart-UnresponsiveService {

$monitor = "CUE"

    foreach($monitors in $monitor)
    {
        $process = Get-Process | ?{$_.Name -eq $monitors}
    
            if($process.Responding -ne $true){
                Stop-Process -Name $process -Force
                sleep 5
                Start-Process -FilePath $process.Path
            }
                
    }

}