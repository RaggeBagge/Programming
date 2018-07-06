Function ParseIni{

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0
                   )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
    $configfileOrContent
    )
    $configfile = $configfileOrContent

    $file =$null
    $ea = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    try{
        if((Test-Path $configfile) -eq $true){ # om test-path är true
        $file = $true}
        elseif((Test-Path $configfile) -eq $false){
            $file= $false}
        else{$file= $false}
    }catch{$file= $false;
    Write-Host "Catched"}
    Finally{
    $ErrorActionPreference = $ea
    }

    $ini = @{}
    $section = "NO_SECTION"
    $ini[$section] = @{}

    $HName = "^\[(.+)\]$"
    $Valuable = "^\s*([^#].+?)\s*[=|:]\s*(.*)"

    if($file){
        switch -Regex -file $configfile {
            $HName {
                $section = $Matches[1].Trim()
                $ini[$section] = @{}
            }
            $Valuable {
                $name, $value = $matches[1..2]
                #skip comments with semicolon
                if (!($name.StartsWith(";"))) {
                    $ini[$section][$name] = $value.Trim()
                }
            }
        }
    }
    elseif(!$file){
        switch -Regex ($configfile){
            $HName {
                $section = $Matches[1].Trim()
                $ini[$section] = @{}
            }
            $Valuable {
                $name, $value = $matches[1..2]
                #skip comments with semicolon
                if (!($name.StartsWith(";"))) {
                    $ini[$section][$name] = $value.Trim()
                }
            }
        }
    } # Return $ini alltså
    $ini
}



# Unit Test
    try{
        $Valu = @("aaaa = bbb","awd = dwadwda, dwad","j3f043 : jdf930j2 ",'[NewSection]',"woop:a3") 
        
        $a= ParseIni -configfileOrContent $Valu
        $a.NO_SECTION.aaaa -eq "bbb"
        $a.NO_SECTION.awd -eq "dwadwda, dwad"
        $a.NO_SECTION.j3f043 -eq "jdf930j2"
        $a.NewSection.woop -eq "a3"
        
        $TestFile = "d:\RemoveThisFile.ini"
        if(Test-Path $TestFile){Remove-Item $TestFile}
        New-Item -Path $TestFile -ItemType File -Value ($Valu|Out-String)
        $b = ParseIni -configfileOrContent $TestFile
        $b.NO_SECTION.aaaa -eq "bbb"
        $b.NO_SECTION.awd -eq "dwadwda, dwad"
        $b.NO_SECTION.j3f043 -eq "jdf930j2"
        $b.NewSection.woop -eq "a3"
    } catch{
        Write-Warning "A test failed inside ParseIni"
    }
    Finally{
        Remove-Variable TestFile, a, b, Valu
    }