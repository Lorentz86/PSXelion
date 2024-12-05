<#
.SYNOPSIS
    Retrieves a list of persons from the Xelion API.

.DESCRIPTION
    This function generates a list of persons from the Xelion API. It allows sorting by name or most recent use (mru) and can include additional user object fields such as status, employment, or keywords. The function supports pagination to retrieve all persons.

.PARAMETER SortBy
    Specifies the sorting criteria for the persons. Valid values are "Name" and "mru". Default is "Name".

.PARAMETER Include
    Specifies additional user object fields to include in the response. Valid values are "status", "employment", and "keywords".

.PARAMETER Name
    Specifies the name parameter to search for a specific person. Leave empty to generate a list of all persons.

.EXAMPLE
    $persons = Get-XelionPerson -SortBy "Name" -Include "status", "employment"
    This example retrieves a list of persons sorted by name and includes the status and employment fields.

.NOTES
    Ensure that the authorization token is valid before making API requests. If the token is expired, run Get-XelionAuthToken to generate a new token.
#>
function Get-XelionPerson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Sort by name, mru (Most Recent Used). Default is Name")]
        [ValidateSet("Name","mru")]
        [string]$SortBy="Name",

        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment separated by a comma")]
        [ValidateSet("status", "employment","keywords")]
        [string[]]$Include,

        [Parameter(Mandatory=$false, HelpMessage="Leave empty to generate a list of all Persons. Use the name parameter to search a specific person")]
        [string]$Name
    )

    try {
        $Persons = @{}
        
        # Adding the SortBy values to the SortBy Key
        $Persons["SortBy"] = $SortBy

        # Adding the Include and Name values to the Persons hashtable
        if ($Include) { $Persons["Include"] = $Include }
        if ($Name) { $Persons["Name"] = $Name }

        # Generate the URL for Persons    
        $url = Get-XelionUrl -Persons $Persons
        Write-Information -MessageData "Current url: $url"

        # Get the headers
        $headers = Get-XelionHeaders

        # First run to get started
        $Result = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -ContentType "application/json"
        $arrayList = [System.Collections.ArrayList]::new()
        $PersonsList = ConvertFrom-XelionObject -Response $Result
        $arrayList.Add($PersonsList) | Out-Null

        # Get all the persons
        while ($true) {
            $oid = $PersonsList.oid | Select-Object -Last 1
            $newuri = Get-XelionUrl -Persons $Persons -Paging $oid
            $Result = Invoke-WebRequest -Uri $newuri -Method Get -Headers $headers -ContentType "application/json"
            $PersonsList = ConvertFrom-XelionObject -Response $Result
            if (!$PersonsList) { break }
            $arrayList.Add($PersonsList)
        }
        return $arrayList
    }
    catch {
        Write-Error -Message "Failed to retrieve persons: $_"
    }
}