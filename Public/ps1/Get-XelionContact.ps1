function Get-XelionContact{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name of the person or organisation to get the contact information")]
        [string]$Name,

        [Parameter(Mandatory=$false, HelpMessage="Sort by name or mru(Most Recent Used,Default). If mru is used include fields can only be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy='mru',

        [Parameter(Mandatory=$false, HelpMessage="Get the private, business or (default) both contact information.")]
        [ValidateSet("Private","Business","Both")]
        [string]$Include="Both",

        [Parameter(Mandatory=$true, HelpMessage="Return information in the folowing templates. Raw csv-all, csv-custom and csv-custom")]
        [ValidateSet("raw","csv-all","csv-custom","csv-compact")]
        [string]$Template
    )

    try {
        if($Template -match "raw")
        {
            # This will get all the contacts
            $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
            $ContactList = [System.Collections.ArrayList]::new()
            foreach($Contact in $AllContacts){
                    Write-Information -MessageData "Current Contact: $($Contact.commonName) `nCurrent OID: $($Contact.oid)"
                    # This wil get detailed contact information
                    $Info = Get-XelionAddressables -oid $contact.oid
                    $ContactList.Add($Info) | Out-Null
                }
                return $ContactList
        }
    }catch{Write-Error "Failed to get Xelion Contact with the $Template format: $_"}

    try {
        if ($Template -match "csv-custom") {
            $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
            $ContactList = [System.Collections.ArrayList]::new()
            foreach ($contact in $AllContacts) {
                $Info = Get-XelionAddressables -oid $contact.oid
                $contactInfo = ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                $ContactList.Add($contactInfo) | Out-Null
            }
            return $ContactList
        }

        if ($Template -match "csv-compact") {
            $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
            $ContactList = [System.Collections.ArrayList]::new()
    
            foreach ($contact in $AllContacts) {
                $Info = Get-XelionAddressables -oid $contact.oid
                $contactInfo = ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                $ContactList.Add($contactInfo) | Out-Null
            }
            return $ContactList
        }
    } catch {Write-Error "Failed to get Xelion Contact with the $Template format: $_"}
}

