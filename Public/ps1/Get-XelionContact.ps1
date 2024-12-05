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
                $Info = Get-XelionAddressables -oid $contact.oid
                $ContactList.Add($Info)
            }
            return $ContactList
        }
    catch {
        <#Do this if a terminating exception happens#>
    }
}

