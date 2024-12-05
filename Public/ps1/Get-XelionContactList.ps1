function Get-XelionContactList{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Credentials to connect to the Xelion API")]
        [ValidateSet("Person","Organisation","All")]
        [string]$Type

    )

    
}