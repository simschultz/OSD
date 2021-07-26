function Start-OOBEDeploy {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$CustomProfile,
        [switch]$AddNetFX3,
        [switch]$AddRSAT,
        [switch]$Autopilot,
        [string]$ProductKey,
        [string[]]$RemoveAppx,
        [switch]$UpdateDrivers,
        [switch]$UpdateWindows,
        [ValidateSet('Enterprise')]
        [string]$SetEdition
    )
    #=======================================================================
    #	Block
    #=======================================================================
    Block-StandardUser
    Block-WindowsVersionNe10
    Block-PowerShellVersionLt5
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-OOBEDeploy"
    Write-Warning "This function is under heavy development and will have frequent changes"
    #=======================================================================
    #   Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OOBEDeploy.log"
    Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    #   Custom Profile
    #=======================================================================
    if ($CustomProfile) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading OOBEDeploy $CustomProfile Custom Profile"
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading OOBEDeploy Default Profile"
    }
    #=======================================================================
    #   Profile OSD OSDeploy
    #=======================================================================
    if ($CustomProfile -in 'OSD','OSDeploy') {
        $AddRSAT = $true
        $Autopilot = $true
        $UpdateDrivers = $true
        $UpdateWindows = $true
        $RemoveAppx = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
        $ProductKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'
    }
    #=======================================================================
    #   Profile BH
    #=======================================================================
    if ($CustomProfile -in 'BH') {
        $AddRSAT = $true
        $Autopilot = $true
        $UpdateDrivers = $true
        $UpdateWindows = $true
        $RemoveAppx = @('CommunicationsApps','OfficeHub','People','Skype','Solitaire','Xbox','ZuneMusic','ZuneVideo')
        $SetEdition = 'Enterprise'
    }
    #=======================================================================
    #   PSGallery
    #=======================================================================
    $PSGalleryIP = (Get-PSRepository -Name PSGallery).InstallationPolicy
    if ($PSGalleryIP -eq 'Untrusted') {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    #=======================================================================
    #	ProductKey
    #=======================================================================
    if ($SetEdition -eq 'Enterprise') {$ProductKey = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'}
    if ($ProductKey) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-WindowsEdition (ChangePK)"
        Invoke-Exe changepk.exe /ProductKey $ProductKey
        Get-WindowsEdition -Online
    }
    #=======================================================================
    #   Autopilot
    #=======================================================================
    if ($Autopilot) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) AutopilotOOBE"
        Write-Host -ForegroundColor DarkCyan "Install-Module AutopilotOOBE -Force"
        Write-Warning "AutopilotOOBE will open in a new PowerShell Window while OOBEDeploy continues in the background"
        Install-Module AutopilotOOBE -Force
        if ($CustomProfile) {
            Start-Process PowerShell.exe -ArgumentList "-Command Start-AutopilotOOBE -CustomProfile $CustomProfile"
        }
        else {
            Start-Process PowerShell.exe -ArgumentList "-Command Start-AutopilotOOBE"
        }
    }
    #=======================================================================
    #	AddRSAT
    #=======================================================================
    if ($AddNetFX3) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Capability NetFX3"
        $AddWindowsCapability = Get-MyWindowsCapability -Match 'NetFX' -Detail
        foreach ($Item in $AddWindowsCapability) {
            if ($Item.State -eq 'Installed') {
                Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
            }
            else {
                Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
            }
        }
    }
    #=======================================================================
    #	AddRSAT
    #=======================================================================
    if ($AddRSAT) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Add Windows Capability RSAT"
        $AddWindowsCapability = Get-MyWindowsCapability -Category Rsat -Detail
        foreach ($Item in $AddWindowsCapability) {
            if ($Item.State -eq 'Installed') {
                Write-Host -ForegroundColor DarkGray "$($Item.DisplayName)"
            }
            else {
                Write-Host -ForegroundColor DarkCyan "$($Item.DisplayName)"
                $Item | Add-WindowsCapability -Online -ErrorAction Ignore | Out-Null
            }
        }
    }
    #=======================================================================
    #	Remove-AppxOnline
    #=======================================================================
    if ($RemoveAppx) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Remove-AppxOnline"

        foreach ($Item in $RemoveAppx) {
            Remove-AppxOnline -Name $Item
        }
    }
    #=======================================================================
    #	UpdateDrivers
    #=======================================================================
    if ($UpdateDrivers) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows Update Drivers"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateDrivers = $false
            }
        }
    }
    if ($UpdateDrivers) {
        Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot
    }
    #=======================================================================
    #	Windows Update Software
    #=======================================================================
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkGray "========================================================================="
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Windows and Microsoft Update Software"
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate PowerShell Module'
                $UpdateWindows = $false
            }
        }
    }
    if ($UpdateWindows) {
        Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
        Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
        #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
        #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
        Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
    }
    #=======================================================================
    #	Stop-Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Stop-Transcript"
    Write-Warning "It is recommended that you restart your computer using Restart-Computer before completing Windows Setup"
    Stop-Transcript
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
}