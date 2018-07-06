<#
.Synopsis
   This will change powershell prompt
.DESCRIPTION
   If you want to add extra status each instance/session,
   type it like this:
   $ExtraPromptStatus ={
   if([bool]($global:DefaultVIServer.Name)){
        Write-Host " - " -NoNewline
        Write-Host "$($global:DefaultVIServer.Name)" -NoNewline -ForegroundColor Magenta}
   }

.EXAMPLE
   $ExtraPromptStatus ={
   if([bool]($global:DefaultVIServer.Name)){
        Write-Host " - " -NoNewline
        Write-Host "$($global:DefaultVIServer.Name)" -NoNewline -ForegroundColor Magenta}
   }
  
   >
#>
function Global:prompt()
{
    $tempBool = $?
    
    #if in registry, change colour.
    if($pwd.provider.name -ne "FileSystem"){
        Write-Host "[" -NoNewline -ForegroundColor DarkGray
        Write-Host $pwd.Provider.Name -NoNewline -ForegroundColor Gray
        Write-Host "]" -NoNewline -ForegroundColor DarkGray
    }

    #Color in the path.
    $pwd.path.split("\")| %{
        Write-Host $_ -NoNewline -ForegroundColor Yellow
        if($_ -ne ""){
            Write-Host "\" -NoNewline -ForegroundColor Gray
        }
        
    }

    #Status: Connected till vCenter
    if([bool]($global:DefaultVIServer.Name)){
        Write-Host " - " -NoNewline
        Write-Host "$($global:DefaultVIServer.Name)" -NoNewline -ForegroundColor Magenta}
    
    #Status: Klockan
    Write-Host " - " -NoNewline
    Write-Host "$((get-date).ToShortTimeString())" -NoNewline -ForegroundColor Green

    #Status: Computer
    Write-Host " - " -NoNewline
    $computer = $env:computername
    Write-Host $computer -NoNewline -ForegroundColor Cyan

    #Status: Timer
    if($time -ne $null -and $time -ne ""){Write-Host " -" -NoNewline;Write-Host " L: $($time.ToShortTimeString())" -ForegroundColor DarkCyan -NoNewline}

    #Status: Add customised statusbar:
    if([bool]$ExtraPromptStatus){
    . $ExtraPromptStatus}

    Write-Host ""

    #See how the last statement went.
    if([bool]$tempBool){
        Write-Host "`b>" -NoNewline -ForegroundColor Green
    }
    else{
        Write-Host "`b>" -NoNewline -ForegroundColor Red
    }
    
    #$host.ui.RawUI.WindowSize.Width Sätt en kontroll på detta och skapa ny rad för status.
    
    return " "

    
    
}