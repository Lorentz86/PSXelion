function Get-XelionContact{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Name of the person or organisation to get the contact information")]
        [string]$Name,

        [Parameter(Mandatory=$false, HelpMessage="Sort by name or mru(Most Recent Used,Default). If mru is used include fields can only be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy='mru',

        [Parameter(Mandatory=$false, HelpMessage="Raw Contact information so you can make your own filter")]
        [switch]$Raw,

        [Parameter(Mandatory=$false, HelpMessage="Get the private, business or (default) both contact information.")]
        [ValidateSet("Private","Business","Both")]
        [string]$Include="Both"

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
                    
                    if($Include -match "Private" -or $Include -match "Both"){
                        $privateEmailCount = 1
                        $privateNumberCount = 1
                        foreach ($privateInformation in $Info.telecomAddresses) {                        
                            if($privateInformation.addressType -match "Email"){
                                Write-Host $privateInformation.address
                                $privateEmailHeader = "PrivateEmail_" + $privateEmailCount
                                $contactInfo | Add-Member -MemberType NoteProperty -Name $privateEmailHeader -Value $privateInformation.address
                                $privateEmailCount++
                            }

                            if($privateInformation.addressType -match "Telephone" -or $privateInformation.addressType -match "Telephone_and_SMS"){
                                $privatePhoneHeader = "PrivatePhone_" + $privateNumberCount
                                $contactInfo | Add-Member -MemberType NoteProperty -Name $privatePhoneHeader -Value $privateInformation.address
                                $privateNumberCount++
                            }
                        }

                    }
                    if ($Include -match "Business" -or $Include -match "Both") {
                        $businessEmailCount = 1
                        $businessNumberCount = 1
                        $CompanyCountNumber = 1
                        $BusinessContacts = $Info.employments

                        foreach ($BusinessContact in $BusinessContacts){
                            $CompanyName = "CompanyName_$CompanyCountNumber"
                            $contactInfo | Add-Member -MemberType NoteProperty -Name $CompanyName -Value $BusinessContact.organisation.name
                            $contactInfo | Add-Member -MemberType NoteProperty -Name "jobTitle_$CompanyCountNumber" -Value $BusinessContact.jobTitle
                            $contactInfo | Add-Member -MemberType NoteProperty -Name "DepartmentName_$CompanyCountNumber" -Value $BusinessContact.departmentName
                            $CompanyCountNumber++
                            foreach($IndividualBusinessInfo in $BusinessContact.telecomAddresses){
                                foreach($BusinessInfo in $IndividualBusinessInfo){
                                    if ($BusinessInfo.addressType -match "Email"){
                                        $businessEmailHeader = "$CompanyName" + "_BusinessEmail_" + $businessEmailCount
                                        $contactInfo | Add-Member -MemberType NoteProperty -Name $businessEmailHeader -Value $BusinessInfo.address
                                        $businessEmailCount++
                                    }
                                    if ($BusinessInfo.addressType -match "Telephone" -or $BusinessInfo.addressType -match "Telephone_and_SMS"){
                                        $businessPhoneHeader = "$CompanyName" + "_BusinessPhone_" + $businessNumberCount
                                        $contactInfo | Add-Member -MemberType NoteProperty -Name $businessPhoneHeader -Value $BusinessInfo.address
                                        $businessNumberCount++
                                    }
                                }
                            }
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

