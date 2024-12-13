function ConvertTo-XelionJsonContact{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment separated by a comma")]
        [ValidateSet("Private", "Business","Both")]
        [string[]]$Include

    )
}