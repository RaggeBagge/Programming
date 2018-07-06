# Script for my Virtual Enviorment using a VmWare Workstation VM as a Hyper-V Host.
# With this script I want to manage the VMs on the Hyper-V Host
# Author: Rasmus Johansson
# !#Do NOT expect a well written script since I'm still in the proccess of learning#!
#

$session = Enter-PSSession -ComputerName "HyperV-Host" -Credential "Administrator"


function rajo-CreateNetworkCard {
Invoke-Command -Session $session -ScriptBlock {}
}

function rajo-getVM {

$scriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("Get-vm")
Invoke-Command -Session $session -ScriptBlock {$scriptBlock}
}

function rajo-newVM {
[string]$name = Read-Host -Prompt "Name of the VM"
$SizeOfRAM = Read-Host -Prompt "Amount of RAM (GB)"
$SizeOfHDD = Read-Host -Prompt "Size of HDD (GB)"



New-VM -Name $Name -MemoryStartupBytes $SizeOfRAM -Generation 2 -SwitchName "External" -NewVHDPath "C:\VM\$Name\$Name.vhdx" -NewVHDSizeBytes $SizeOfHDD


}

function rajo-removeVM($name) {

}