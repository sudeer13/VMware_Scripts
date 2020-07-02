<#DESCRIPTION
    Author  : Sudeer Vadali
    Title   : Display_Guest_Disk_Usage.ps1
    Version : 1.0
    Update  : This is the first version
    Date    : 01/06/2019
    
    Description	: This script will generate a custom report to Display the guest disk usage
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
        $MyCollection = @()
        $AllVMs = Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template}
        $SortedVMs = $AllVMs | Select *, @{N="NumDisks";E={@($_.Guest.Disk.Length)}} | Sort-Object -Descending NumDisks
        ForEach ($VM in $SortedVMs){
            $Details = New-object PSObject
            $Details | Add-Member -Name Name -Value $VM.name -Membertype NoteProperty
            $DiskNum = 0
            Foreach ($disk in $VM.Guest.Disk){
                $Details | Add-Member -Name "Disk$($DiskNum)path" -MemberType NoteProperty -Value $Disk.DiskPath
                $Details | Add-Member -Name "Disk$($DiskNum)Capacity(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.Capacity/ 1MB))
                $Details | Add-Member -Name "Disk$($DiskNum)FreeSpace(MB)" -MemberType NoteProperty -Value ([math]::Round($disk.FreeSpace / 1MB))
                $DiskNum++
            }
            $MyCollection += $Details
        }
    $MyCollection | Out-GridView
}
catch {
		Write-Host "Unable to Get Data due to " $_
}
