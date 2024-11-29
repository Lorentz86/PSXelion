<#
.SYNOPSIS
    Generates a paging URL for Xelion API requests.

.DESCRIPTION
    This function generates a paging URL for cursor-based pagination in Xelion API requests. It constructs the URL based on whether the results should be fetched after or before a specified object ID.

.PARAMETER resultsAfter
    A boolean parameter indicating whether to fetch results after the specified object ID. Default is `$true`. Set to `$false` to fetch results before the specified ID.

.PARAMETER Paging
    The object ID (oid) of the last object for pagination.

.EXAMPLE
    $pagingUrl = Get-XelionPagingUrl -resultsAfter $true -Paging "12345"
    This example generates a paging URL to fetch results after the object with ID "12345".

.NOTES
    Ensure that the Paging parameter is provided to generate a valid paging URL.
#>
function Get-XelionPagingUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Pagination is cursor based. The parameters before and after request results before or after the specified ID respectively. Default is `$true, change to `$false to use the before request")]
        [System.Boolean]$resultsAfter = $true,
    
        [Parameter(Mandatory=$false, HelpMessage="Object ID (oid) of the last object")]
        [string]$Paging
    )
    try {
        $default = if ($resultsAfter) { "&after=" } else { "&before=" }
        
        return $default + $Paging
    }
    catch {
        Write-Error "Failed to create Paging URL: $_"
    }
}