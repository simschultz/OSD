﻿function Set-SetupCompleteHPAppend {

    $ScriptsPath = "C:\Windows\Setup\scripts"
    if (!(Test-Path -Path $ScriptsPath)){New-Item -Path $ScriptsPath} 

    $RunScript = @(@{ Script = "SetupComplete"; BatFile = 'SetupComplete.cmd'; ps1file = 'SetupComplete.ps1';Type = 'Setup'; Path = "$ScriptsPath"})
    $PSFilePath = "$($RunScript.Path)\$($RunScript.ps1File)"

    if (Test-Path -Path $PSFilePath){
        Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/deviceshp.psm1')"
        #Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/modules/eq-winpe.psm1')"
        #Add-Content -Path $PSFilePath "Invoke-Expression (Invoke-RestMethod -Uri 'functions.osdcloud.com' -ErrorAction SilentlyContinue)"
        #Add-Content -Path $PSFilePath "osdcloud-WinpeSetEnvironmentVariables"
        #Add-Content -Path $PSFilePath "osdcloud-InstallModuleHPCMSL -ErrorAction SilentlyContinue"
        Add-Content -Path $PSFilePath 'Write-Host "Running HP Tools in SetupComplete" -ForegroundColor Green'
        if ($Global:OSDCloud.HPIADrivers -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Drivers" -ForegroundColor Magenta'
            if (Test-Path -path "C:\OSDCloud\HPIA\Repo"){Add-Content -Path $PSFilePath "osdcloud-RunHPIA -OfflineMode True -Category Drivers"}
            else {Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category Drivers"}
        }
        if (($Global:OSDCloud.HPIAFirmware -eq $true) -and ($Global:OSDCloud.HPIAAll  -ne $true)){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Firmware" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category Firmware"
        } 
        if (($Global:OSDCloud.HPIASoftware -eq $true) -and ($Global:OSDCloud.HPIAAll  -ne $true)){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Software" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category Software"
        } 
        if ($Global:OSDCloud.HPIAAll -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HPIA for Software" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPIAExecute -Category All"
        }            
        if ($Global:OSDCloud.HPTPMUpdate -eq $true){
            Add-Content -Path $PSFilePath 'if (Get-HPTPMDetermine -ne "False"){Write-Host "Updating TPM Firmware" -ForegroundColor Magenta}'
            Add-Content -Path $PSFilePath 'if (Get-HPTPMDetermine -ne "False"){osdcloud-HPTPMUpdate}'
        } 
        if ($Global:OSDCloud.HPBIOSUpdate -eq $true){
            Add-Content -Path $PSFilePath 'Write-Host "Running HP System Firmware" -ForegroundColor Magenta'
            Add-Content -Path $PSFilePath "osdcloud-HPBIOSUpdate"
        }
        Add-Content -Path $PSFilePath "osdcloud-HPBIOSSetSetting -SettingName 'Virtualization Technology (VTx)' -Value 'Enable'"
    }
    else {
    Write-Output "$PSFilePath - Not Found"
    }
}