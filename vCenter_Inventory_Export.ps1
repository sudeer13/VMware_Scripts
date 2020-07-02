<#DESCRIPTION
    Author  : Sudeer Kumar Vadali
    Title   : vCenter_Inventory_Export.ps1
    Version : 1.0
    Update  : This is the first version
    Date    : 01/06/2019
    
    Description	:	This script will generate a custom report for Virtual Machines info for inventory and Export to CSV
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
        results =@()
        $vms = (Get-VM)

        foreach($vm in $vms){
            $row = "" | Select Name, HostName, PowerState, IP, VLAN, OperatingSystem, Host, Cluster
            $row.Name = $vm.Name
            $row.HostName = $vm.Guest.HostName
            $row.OperatingSystem = $vm.Guest.OSFullName
            $row.PowerState = $vm.PowerState
            $row.IP = ($vm.Guest | ForEach-Object {$_.IPAddress} | Where-Object {$_.split(".").length -eq 4}) -join ","  
            $row.VLAN = ($vm | Get-NetworkAdapter | ForEach-Object {$_.NetworkName}) -join ","
            $row.Cluster = (Get-Cluster -VM $vm)
            $row.Host = $vm.VMHost.Name
            $results += $row
        }
        $results | Export-Csv "C:\Invetory_Export.csv" -UseCulture -NoTypeInformation 
}
catch {
		Write-Host "Unable to Get Data due to " $_ 
}
