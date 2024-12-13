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
        [string]$Include="Both",

        [Parameter(Mandatory=$false, HelpMessage="The preconfigured structures are csv and json. If you want to create your own, choose raw")]
        [ValidateSet("raw","csv","json")]
        [string]$Format="json"
    )

    try {
        if($Format -match "raw")
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
    }catch{
        Write-Error "Failed to get Xelion Contact with the $Format format: $_"
    }

    try {
        # This part is to generate the csv format style
        if ($Format -match "csv") {
            $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
            $ContactList = [System.Collections.ArrayList]::new()
    
            foreach ($contact in $AllContacts) {
                $Info = Get-XelionAddressables -oid $contact.oid
    
                $contactInfo = [PSCustomObject]@{
                    displayName = $Info.commonName
                    givenName   = $Info.givenName
                    lastname    = $Info.lastname
                    objectType  = $Info.objectType
                }
    
                if ($Include -match "Private" -or $Include -match "Both") {
                    $privateEmailCount = 1
                    $privateNumberCount = 1
                    foreach ($privateInformation in $Info.telecomAddresses) {
                        if ($privateInformation.addressType -match "Email") {
                            $privateEmailHeader = "PrivateEmail_" + $privateEmailCount
                            $contactInfo | Add-Member -MemberType NoteProperty -Name $privateEmailHeader -Value $privateInformation.address
                            $privateEmailCount++
                        }
    
                        if ($privateInformation.addressType -match "Telephone" -or $privateInformation.addressType -match "Telephone_and_SMS") {
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
    
                    foreach ($BusinessContact in $BusinessContacts) {
                        $CompanyName = "CompanyName_$CompanyCountNumber"
                        $contactInfo | Add-Member -MemberType NoteProperty -Name $CompanyName -Value $BusinessContact.organisation.name
                        $contactInfo | Add-Member -MemberType NoteProperty -Name "jobTitle_$CompanyCountNumber" -Value $BusinessContact.jobTitle
                        $contactInfo | Add-Member -MemberType NoteProperty -Name "DepartmentName_$CompanyCountNumber" -Value $BusinessContact.departmentName
                        $CompanyCountNumber++
                        foreach ($IndividualBusinessInfo in $BusinessContact.telecomAddresses) {
                            foreach ($BusinessInfo in $IndividualBusinessInfo) {
                                if ($BusinessInfo.addressType -match "Email") {
                                    $businessEmailHeader = "$CompanyName" + "_BusinessEmail_" + $businessEmailCount
                                    $contactInfo | Add-Member -MemberType NoteProperty -Name $businessEmailHeader -Value $BusinessInfo.address
                                    $businessEmailCount++
                                }
                                if ($BusinessInfo.addressType -match "Telephone" -or $BusinessInfo.addressType -match "Telephone_and_SMS") {
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
    } catch {
        "Failed to get Xelion Contact with the $Format format: $_"
    }
    
    try {
        # This part is to generate the Json Style Format
        if ($format -match "json") {
            $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
            $ContactList = [System.Collections.ArrayList]::new()
    
            foreach ($contact in $AllContacts) {
                $Info = Get-XelionAddressables -oid $contact.oid
    
                $contactInfo = [PSCustomObject]@{
                    displayName = $Info.commonName
                    givenName   = $Info.givenName
                    lastname    = $Info.lastname
                    objectType  = $Info.objectType
                }
    
                if ($Include -match "Private" -or $Include -match "Both") {
                    $contactInfo | Add-Member -MemberType NoteProperty -Name "PrivateEmail" -Value @()
                    $contactInfo | Add-Member -MemberType NoteProperty -Name "PrivatePhone" -Value @()
                    foreach ($privateInformation in $Info.telecomAddresses) {
                        if ($privateInformation.addressType -match "Email") {
                            $contactInfo.PrivateEmail += $privateInformation.address
                        }
        
                        if ($privateInformation.addressType -match "Telephone" -or $privateInformation.addressType -match "Telephone_and_SMS") {
                            $contactInfo.PrivatePhone += $privateInformation.address
                        }
                    }
                }
        
                if ($Include -match "Business" -or $Include -match "Both") {
                    $CompanyCountNumber = 1
                    $BusinessContacts = $Info.employments
        
                    foreach ($BusinessContact in $BusinessContacts) {
                        $CompanyName = "Company_$CompanyCountNumber"
                        $EmailHeader = "$CompanyName" + "_Email"
                        $PhoneHeader = "$CompanyName" + "_Phone"
                        $contactInfo | Add-Member -MemberType NoteProperty -Name $CompanyName -Value $BusinessContact.organisation.name
                        $contactInfo | Add-Member -MemberType NoteProperty -Name "jobTitle_$CompanyCountNumber" -Value $BusinessContact.jobTitle
                        $contactInfo | Add-Member -MemberType NoteProperty -Name "DepartmentName_$CompanyCountNumber" -Value $BusinessContact.departmentName
                        $contactInfo | Add-Member -MemberType NoteProperty -Name $EmailHeader -Value @()
                        $contactInfo | Add-Member -MemberType NoteProperty -Name $PhoneHeader -Value @()
                        $CompanyCountNumber++
                        foreach ($IndividualBusinessInfo in $BusinessContact.telecomAddresses) {
                            foreach ($BusinessInfo in $IndividualBusinessInfo) {
                                if ($BusinessInfo.addressType -match "Email") {
                                    $contactInfo.$EmailHeader += $BusinessInfo.address
                                }
                                if ($BusinessInfo.addressType -match "Telephone" -or $BusinessInfo.addressType -match "Telephone_and_SMS") {
                                    $contactInfo.$PhoneHeader += $BusinessInfo.address
                                }
                            }
                        }
                    }
                    $ContactList.Add($contactInfo) | Out-Null
                }
            }
            return $ContactList
        }
    } catch {
        "Failed to get Xelion Contact with the $Format format: $_"
    }
}

