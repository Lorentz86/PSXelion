function Get-XelionContactList{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Filter what contacts you want to have. Can have more then one. Leave empty to receive all of them but I do not advice this course of action. Can take a while to generate. ")]
        [ValidateSet("Person","Organisation","X1Object","UnknownAddressable")]
        [string[]]$Type,

        [Parameter(Mandatory=$false, HelpMessage="Get the private, business or (default) both contact information.")]
        [ValidateSet("Private","Business","Both")]
        [string]$Include="Both",

        [Parameter(Mandatory=$true, HelpMessage="Return information in the folowing templates. Raw csv-all, csv-custom and csv-custom")]
        [ValidateSet("raw","csv-all","csv-custom","csv-compact")]
        [string]$Template

    )
    $Types = $Type | Select-Object -Unique
    
    try{
        if($Template -match "raw"){
            $ContactList = [System.Collections.ArrayList]::new()
            Foreach ($ContactType in $Types){
                $AllContacts = Get-XelionAddressables -SortBy "Name" -Filter $ContactType
                foreach($Contact in $AllContacts){
                        Write-Information -MessageData "Current Contact: $($Contact.commonName) `nCurrent OID: $($Contact.oid)"
                        # This wil get detailed contact information
                        $Info = Get-XelionAddressables -oid $contact.oid                   
                        $ContactList.Add($Info) | Out-Null
                    }
                }
            }
            return $ContactList
        }
        catch{
            Write-Error "Could not generate list with $Template format: $_"
        }

    try {
        if ($Template -match "csv-custom") {
            $ContactList = [System.Collections.ArrayList]::new()
            Foreach ($ContactType in $Types){
                $AllContacts = Get-XelionAddressables -SortBy "Name" -Filter $ContactType
                foreach ($contact in $AllContacts) {
                    $Info = Get-XelionAddressables -oid $contact.oid
                    $contactInfo = ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                    $ContactList.Add($contactInfo) | Out-Null
                }
            }         
            return $ContactList
        }

        if ($Template -match "csv-compact") {
            Foreach ($ContactType in $Types){
                $AllContacts = Get-XelionAddressables -SortBy "Name" -Filter $ContactType
                foreach ($contact in $AllContacts) {
                    $Info = Get-XelionAddressables -oid $contact.oid
                    $contactInfo = ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                    $ContactList.Add($contactInfo) | Out-Null
                }
            }         
            return $ContactList
        }
    } catch {Write-Error "Failed to get Xelion Contact with the $Template format: $_"}
}