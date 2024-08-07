function Get-LocalDiskPartition {
    [CmdletBinding()]
    param ()

    #=================================================
    #	Return
    #=================================================
    Return (Get-OSDPartition | Where-Object {$_.IsUSB -eq $false})
    #=================================================
}
