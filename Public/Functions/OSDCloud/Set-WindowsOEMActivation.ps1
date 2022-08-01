Function Set-WindowsOEMActivation {
    $computer = $env:computername
    $ProductKey = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
    if ($ProductKey) {
        Write-Output "Setting Key: $ProductKey" 
        $service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
        $service.InstallProductKey($ProductKey) | Out-Null
        $service.RefreshLicenseStatus() | Out-Null
        $service.RefreshLicenseStatus() | Out-Null
        Write-Output  "Successfully Applied Key"
    }else{
	    Write-Output 'Key not found!'
    }
}