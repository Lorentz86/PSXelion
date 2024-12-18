function ConvertTo-XelionTemplate{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Return information in the folowing templates. Raw csv-all, csv-custom and csv-custom")]
        [ValidateSet("csv-all","csv-custom","csv-compact")]
        [string]$Template,

        [Parameter(Mandatory=$false, HelpMessage="Get the private, business or (default) both contact information.")]
        [ValidateSet("Private","Business","Both")]
        [string]$Addressable,

        [Parameter(Mandatory=$true, HelpMessage="The Xelion Object to convert to a template.")]
        $XelionObject

    )

    # Custom template
    if($Addressable){
        if($Template -match "csv-custom"){
            $contactInfo = [PSCustomObject]@{
                displayName = $Info.commonName
                givenName   = $Info.givenName
                lastname    = $Info.lastname
                objectType  = $Info.objectType
            }

            if ($Addressable -match "Private" -or $Addressable -match "Both") {
                $privateEmailCount = 1
                $privateNumberCount = 1
                foreach ($Information in $XelionObject.telecomAddresses) {
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

            if ($Addressable -match "Business" -or $Addressable -match "Both") {
                $businessEmailCount = 1
                $businessNumberCount = 1
                $CompanyCountNumber = 1
                $BusinessContacts = $XelionObject.employments

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
            return $contactInfo
        }
        
        # Compact Template
        if($Template -match "csv-compact"){
                
            $contactInfo = [PSCustomObject]@{
                displayName = $Info.commonName
                givenName   = $Info.givenName
                lastname    = $Info.lastname
                objectType  = $Info.objectType
            }

            if ($Addressable -match "Private" -or $Addressable -match "Both") {
                $contactInfo | Add-Member -MemberType NoteProperty -Name "PrivateEmail" -Value @()
                $contactInfo | Add-Member -MemberType NoteProperty -Name "PrivatePhone" -Value @()
                foreach ($privateInformation in $XelionObject.telecomAddresses) {
                    if ($privateInformation.addressType -match "Email") {
                        $contactInfo.PrivateEmail += $privateInformation.address
                    }
    
                    if ($privateInformation.addressType -match "Telephone" -or $privateInformation.addressType -match "Telephone_and_SMS") {
                        $contactInfo.PrivatePhone += $privateInformation.address
                    }
                }
            }
    
            if ($Addressable -match "Business" -or $Addressable -match "Both") {
                $CompanyCountNumber = 1
                $BusinessContacts = $XelionObject.employments
    
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
            }      
            return $contactInfo
        }
    }
}
        
