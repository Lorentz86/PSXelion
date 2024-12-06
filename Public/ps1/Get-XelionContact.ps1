function Get-XelionContact{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name of the person or organisation to get the contact information")]
        [string]$Name
    )

    try {
        $AllContacts = Get-XelionAddressables -name $Name -SortBy mru
        
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

