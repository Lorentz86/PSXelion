function Get-XelionContact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Name of the person or organisation to get the contact information")]
        [string]$Name,

        [Parameter(Mandatory=$false, HelpMessage="OID of the user.")]
        [string]$oid,

        [Parameter(Mandatory=$false, HelpMessage="Sort by name or mru (Most Recent Used, Default). If mru is used, include fields can only be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy='mru',

        [Parameter(Mandatory=$false, HelpMessage="Get the private, business or (default) both contact information.")]
        [ValidateSet("Private","Business","Both")]
        [string]$Include="Both",

        [Parameter(Mandatory=$true, HelpMessage="Return information in the following templates: raw, csv-all, csv-custom, and csv-compact.")]
        [ValidateSet("raw","csv-all","csv-custom","csv-compact")]
        [string]$Template
    )
    begin {
        if (-not $Name -and -not $oid) {
            throw "Either 'Name' or 'oid' must be specified."
        }
    }
    process {
        try {
            $AllContacts = ""
            if ($oid) {
                Write-Information -MessageData "Running Switch statement."
                switch ($Template) {
                    "raw" { return Get-XelionAddressables -oid $oid }
                    "csv-custom" {
                        $Info = Get-XelionAddressables -oid $oid
                        return ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                    }
                    "csv-compact" {
                        $Info = Get-XelionAddressables -oid $oid
                        return ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                    }
                }
            } else {
                Write-Information -MessageData "Getting contact information for: $Name"
                $AllContacts = Get-XelionAddressables -name $Name -SortBy $SortBy
            }
            $ContactList = [System.Collections.ArrayList]::new()
        } catch {
            Write-Error "Failed to get Xelion Addressables: $_"
        }
        try {
            if ($Template -match "raw") {
                foreach ($Contact in $AllContacts) {
                    Write-Information -MessageData "Current Contact: $($Contact.commonName) `nCurrent OID: $($Contact.oid)"
                    $Info = Get-XelionAddressables -oid $Contact.oid
                    $ContactList.Add($Info) | Out-Null
                }
                return $ContactList
            }
        } catch {
            Write-Error "Failed to get Xelion Contact with the $Template format: $_"
        }
        try {
            if ($Template -match "csv-custom") {
                foreach ($Contact in $AllContacts) {
                    $Info = Get-XelionAddressables -oid $Contact.oid
                    $contactInfo = ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                    $ContactList.Add($contactInfo) | Out-Null
                }
                return $ContactList
            }
            if ($Template -match "csv-compact") {
                foreach ($Contact in $AllContacts) {
                    $Info = Get-XelionAddressables -oid $Contact.oid
                    $contactInfo = ConvertTo-XelionTemplate -Template $Template -Addressable $Include -XelionObject $Info
                    $ContactList.Add($contactInfo) | Out-Null
                }
                return $ContactList
            }
        } catch {
            Write-Error "Failed to get Xelion Contact with the $Template format: $_"
        }
    }
}