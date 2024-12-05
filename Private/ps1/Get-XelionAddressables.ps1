<#
.SYNOPSIS
    Retrieves a list of addressable objects from the Xelion API.

.DESCRIPTION
    This function generates a list of addressable objects from the Xelion API. It allows sorting by name or most recent use (mru) and can include additional user object fields such as status, employment, or keywords. The function supports pagination to retrieve all addressable objects.

.PARAMETER SortBy
    Specifies the sorting criteria for the addressable objects. Valid values are "Name" and "mru". Default is "Name".

.PARAMETER Include
    Specifies additional user object fields to include in the response. Valid values are "status", "employment", and "keywords".

.PARAMETER Name
    Specifies the name parameter to search for a specific person. Leave empty to generate a list of all persons.

.EXAMPLE
    $addressables = Get-XelionAddressables -SortBy "Name" -Include "status", "employment"
    This example retrieves a list of addressable objects sorted by name and includes the status and employment fields.

.NOTES
    Ensure that the authorization token is valid before making API requests. If the token is expired, run Get-XelionAuthToken to generate a new token.
#>
function Get-XelionAddressables {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Sort by name, mru (Most Recent Used). If mru is used include fields can only be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy,

        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment separated by a comma")]
        [ValidateSet("status", "employment","keywords")]
        [string[]]$Include,

        [Parameter(Mandatory=$false, HelpMessage="Leave empty to generate a list of all Persons. Use the name parameter to search a specific person",ValueFromPipeline=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false, HelpMessage="The oid of the person",ValueFromPipeline=$true)]
        [string]$oid
    )

    try {
        # Making the Addressables hashtable
        $Addressables = @{}
        
        # Adding the SortBy values to the SortBy Key
        

        # Adding the Include and Name values to the Addressables hashtable
        if ($SortBy){ $Addressables["SortBy"] = $SortBy}
        if ($Include) { $Addressables["Include"] = $Include }
        if ($Name) { $Addressables["Name"] = $Name }
        if ($oid) { $Addressables["oid"] = $oid }

        # Generate the URL for Addressables    
        $url = Get-XelionUrl -Addressables $Addressables
        Write-Information -MessageData "Current url: $url"

        # Get the headers
        $headers = Get-XelionHeaders

        # First run to get started
        $Result = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -ContentType "application/json"
        $arrayList = [System.Collections.ArrayList]::new()
        $AddressablesList = ConvertFrom-XelionObject -Response $Result
        foreach ($item in $AddressablesList){$arrayList.Add($item) | Out-Null}
        if($arrayList.count -lt 8){
            Write-Information -MessageData "The list contains:  $($arrayList.count) items"
            return $arrayList
        }
        # Get all the addressables
        while ($true) {
            $oid = $AddressablesList.oid | Select-Object -Last 1
            Write-Information "The list contains:  $($arrayList.count) items. Paging from $($oid)"
            $newuri = Get-XelionUrl -Addressables $Addressables -Paging $oid
            $Result = Invoke-WebRequest -Uri $newuri -Method Get -Headers $headers -ContentType "application/json"           
            $AddressablesList = ConvertFrom-XelionObject -Response $Result
            if (!$AddressablesList) { break }
            $arrayList.Add($AddressablesList) | Out-Null
        }
        return $arrayList.ToArray()
    }
    catch {
        Write-Error -Message "Failed to retrieve addressables: $_"
    }
}