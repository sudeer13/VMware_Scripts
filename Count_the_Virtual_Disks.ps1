<#DESCRIPTION
    Author  : Sudeer Vadali
    Title   : Count_the_Virtual_Disks.ps1
    Version : 1.0
    Update  : This is the first version
    Date    : 01/06/2019
    
    Description	: This script will generate a custom report for Count the virtual disks of each VM
#>

#Login Details
$VIServer = "Enter IP or Hostname for your VI Server"
$VIUser = "Enter Username"
$VIPass = "Enter Password"

try {
		Add-PSSnapin VMware.VimAutomation.Core
		Connect-VIServer -server $VIServer -user $VIUser -pass $VIPass -ErrorAction Stop -WarningAction 0
	}
catch {  
        Write-Host "Unable to connect vcenter server due to exception" $_
		exit
	}
try {
        Get-VM -name * |Select Name,@{N=’vDisk’;E={($_.ExtensionData.Config.Hardware.Device | where{$_ -is [VMware.Vim.VirtualDisk]}).Count}}
		
}
catch {
		Write-Host "Unable to Get Data Due to" $_
	}
