function Get-XelionContact{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name of the person or organisation to get the contact information")]
        [string]$Name,

        [Parameter(Mandatory=$false, HelpMessage="Sort by name or mru(Most Recent Used,Default). If mru is used include fields can only be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy='mru',

        [Parameter(Mandatory=$false, HelpMessage="Raw Contact information so you can make your own filter")]
        [switch]$Raw
    )

    try {
            if($Raw.IsPresent){
                $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
        
                $ContactList = [System.Collections.ArrayList]::new()
                foreach($Contact in $AllContacts){
                        Write-Information -MessageData "Current Contact: $($Contact.commonName) `nCurrent OID: $($Contact.oid)"
                        $Info = Get-XelionAddressables -oid $contact.oid
                        $ContactList.Add($Info) | Out-Null
                    }
                    return $ContactList
            }
            else{
                $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
                $ContactList = [System.Collections.ArrayList]::new()
                
                Foreach($contact in $AllContacts) {
                    $Info = Get-XelionAddressables -oid $contact.oid

                    $contactInfo = [PSCustomObject]@{
                    displayName = $Info.commonName
                    givenName = $Info.givenName
                    lastname = $Info.lastname
                    objectType = $Info.objectType
                    }

                    $privateEmailCount = 1
                    $privateNumberCount = 1
                    foreach ($privateInformation in $Info.telecomAddresses) {                        
                        if($privateInformation.addressType -match "Email"){
                            Write-Host $privateInformation.address
                            $privateEmailHeader = "PrivateEmail" + $privateEmailCount
                            $contactInfo | Add-Member -MemberType NoteProperty -Name $privateEmailHeader -Value $privateInformation.address
                            $privateEmailCount++
                        }

                        if($privateInformation.addressType -match "Telephone"){
                            $privatePhoneHeader = "PrivatePhone" + $privateNumberCount
                            $contactInfo | Add-Member -MemberType NoteProperty -Name $privatePhoneHeader -Value $privateInformation.address
                            $privateNumberCount++
                        }
                    }
                    $ContactList.Add($contactInfo) | Out-Null
                }
                return $ContactList
            }

        }
    catch {
        Write-Error "Could not get contact information: $_"
    }
}

