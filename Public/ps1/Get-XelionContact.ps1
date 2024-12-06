function Get-XelionContact{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name of the person or organisation to get the contact information")]
        [string]$Name,

        [Parameter(Mandatory=$false, HelpMessage="Sort by name or mru(Most Recent Used,Default). If mru is used include fields can only be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy='mru'
    )

    try {
        $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
        
        $ContactList = [System.Collections.ArrayList]::new()
        foreach($Contact in $AllContacts){
                Write-Information -MessageData "Current Contact: $($Contact.commonName) `nCurrent OID: $($Contact.oid)"
                $Info = Get-XelionAddressables -oid $contact.oid
                $ContactList.Add($Info) | Out-Null
            }
            return $ContactList
        }
    catch {
        Write-Error "Could not get contact information: $_"
    }
}

