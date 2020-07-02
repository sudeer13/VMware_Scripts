<#DESCRIPTION

    Author  : Sudeer Vadali
    Title   : VMware_Snapshot_Removal.ps1
    Version : 1.0
    Update  : This is the first version
    Date    : 25/01/2018
    

    Description	: This script is designed to delete all snapshots created with the with name "Patching" and if it is older than 2 days.(for example we will take snapshots during patching time with name "Windows Patching" or "Schedule Patching 16/04/2020")   )
						it will delet all snapshots one by one in sequence.
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
		#Gets the list of snapshots created and saves in $vms.
		$vms=Get-VM | Get-SnapShot | Select vm,@{n='SnapShotName';e={$_.name}},@{n='SizeInGB'; e={[math]::Round($_.sizeGB,3)}},created
		
		#Saves VM's list in file which are having snapshots
		$r = $vms | select VM | Out-File 'C:\Temp\vmsnapshotlist.txt'
		
		#Prints the list of snapshots
		if ($vms -eq $null) {
				write-host "No Snapshots found"
				exit
			}
		else {
			write-host "List of Snapshots:"
			$vms
			}
		
		#Gets the content in file and saves in $k
		$k=(Get-Content -Path 'C:\Temp\vmsnapshotlist.txt')
		$c=0
		for ($i=3; $i -lt ($k.Length-2); $i++){
			#Checks Snapshot of each VM if it is having snapshot with name Patching and if it is older than 2 days.
			if ($k[$i] -match "dd-server" -or $k[$i] -match "pms"){
				$delVms =get-vm -Name $k[$i].trim() | get-snapshot | where {($_.Name -match "Patching") -and (((Get-Date)-($_.created)).days -ge 2)} 
			if ($delVms -ne $null){
				Write-Host "Deleted VM snapshot on" $delVms.vm
				#Deletes the snapshot with name patching and older than 2 days
				$delVms | Remove-Snapshot -confirm:$false
				$c++
			}
		}
		else{
			$delVms =get-vm -Name $k[$i].trim() | get-snapshot | where {($_.Name -match "Patching") -and (((Get-Date)-($_.created)).days -ge 4)} 
			if ($delVms -ne $null){
				Write-Host "Deleted VM snapshot on" $delVms.vm
				#Deletes the snapshot with name patching and older than 4 days
				$delVms | Remove-Snapshot -confirm:$false
				$c++
			}
		}
	}
	if ($c -eq 0){
		Write-Host "No Patching Snapshots to delete which are older."
	}
}
catch {
		Write-Host "Unable to delete snapshot due to exception" $_
	}
