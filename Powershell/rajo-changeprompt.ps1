function change-prompt {

$loc = Get-Location

Write-Host "[" -NoNewline -ForegroundColor DarkGray
Write-Host $loc.path -NoNewline -ForegroundColor Yellow
Write-Host "]" -NoNewline -ForegroundColor DarkGray


$timestamp = Get-Date -Format hh:mm:ss

Write-Host " - " -NoNewline
Write-Host $env:COMPUTERNAME -NoNewline -ForegroundColor Cyan
Write-Host " - " -NoNewline
Write-Host $timestamp -NoNewline

Write-Host "
> "


}