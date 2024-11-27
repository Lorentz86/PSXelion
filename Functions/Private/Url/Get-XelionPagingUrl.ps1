function Get-XelionPagingUrl{
    param(
        [Parameter(Mandatory=$false, HelpMessage="Object ID (oid) of the last object")]
        [string]$Paging
    )
    $default = "after="
    return $default + $Paging
}