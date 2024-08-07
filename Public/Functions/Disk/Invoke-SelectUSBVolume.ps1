function Invoke-SelectUSBVolume {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]$Input,
        [int]$MinimumSizeGB = 1,

        [ValidateSet('FAT32','NTFS')]
        [string]$FileSystem,

        [System.Management.Automation.SwitchParameter]
        $Skip,
        
        [System.Management.Automation.SwitchParameter]
        $SelectOne
    )
    #=================================================
    #	Get-Volume
    #=================================================
    if ($Input) {
        $Results = $Input
    } else {
        $Results = Get-USBVolume | Sort-Object -Property DriveLetter | `
        Where-Object {$_.SizeGB -gt $MinimumSizeGB}
    }
    #=================================================
    #	Filter the File System
    #=================================================
    if ($PSBoundParameters.ContainsKey('FileSystem')) {
        $Results = $Results | Where-Object {$_.FileSystem -eq $FileSystem}
    }
    #=================================================
    #	Process Results
    #=================================================
    if ($Results) {
        #=================================================
        #	There was only 1 Item, then we will select it automatically
        #=================================================
        if ($PSBoundParameters.ContainsKey('SelectOne')) {
            Write-Verbose "Automatically select "
            if (($Results | Measure-Object).Count -eq 1) {
                $SelectedItem = $Results
                Return $SelectedItem
            }
        }
        #=================================================
        #	Table of Items
        #=================================================
        $Results | Select-Object -Property DriveLetter, FileSystemLabel,`
        SizeGB, SizeRemainingGB, SizeRemainingMB, DriveType | `
        Format-Table | Out-Host
        #=================================================
        #	Select an Item
        #=================================================
        if ($PSBoundParameters.ContainsKey('Skip')) {
            do {$Selection = Read-Host -Prompt "Select a USB Volume by DriveLetter, or press S to SKIP"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter) -or ($Selection -eq 'S'))
            
            if ($Selection -eq 'S') {Return $false}
        }
        else {
            do {$Selection = Read-Host -Prompt "Select a USB Volume by DriveLetter"}
            until (($Selection -ge 0) -and ($Selection -in $Results.DriveLetter))
        }
        #=================================================
        #	Return Selection
        #=================================================
        Return ($Results | Where-Object {$_.DriveLetter -eq $Selection})
        #=================================================
    }
}
