<#DESCRIPTION
    Author  : Sudeer Vadali
    Title   : Virtual_Machines_With_RDM.ps1
    Version : 1.0
    Update  : This is the first version
    Date    : 01/05/2018
    
    Description	: This script will generate a custom report for all VirtualMachines with an RDM attached and Export to CSV
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
        $report = @()
        $vms = Get-VM -Location Production_Test  | Get-View
        foreach($vm in $vms){
            foreach($dev in $vm.Config.Hardware.Device){
                if(($dev.gettype()).Name -eq "VirtualDisk"){
                    if(($dev.Backing.CompatibilityMode -eq "physicalMode") -or ($dev.Backing.CompatibilityMode -eq "virtualMode")){
                        $row = "" | select VMName, Host, RDM_DeviceName, RDM_FileName, Mode
                        $row.VMName = $vm.Name
                        $getvm = Get-VM $row.VMName
                        $row.Host = $getvm.VMHost
                        $row.RDM_DeviceName = $dev.Backing.DeviceName
                        $row.RDM_FileName = $dev.Backing.FileName
                        $row.Mode = $dev.Backing.CompatibilityMode
                        $report += $row
                    }
                }
            }
        }
    # Export to CSV all VirtualMachines with an RDM attached
    $report | Export-Csv "c:\vms-with-RDM.csv" -NoTypeInformation -UseCulture
}
catch {
		Write-Host "Unable to Get Data due to " $_ 
}
