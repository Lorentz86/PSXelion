function Get-XelionContactList{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Credentials to connect to the Xelion API")]
        [ValidateSet("Person","Organisation","X1Object","UnknownAddressable","All")]
        [string[]]$Type

    )
    
    try{
        $Info = Get-XelionAddressables -Filter $Type
        return $Info
    }
    catch{
        Write-Error "Could not generate list: $_"
    }
    
}