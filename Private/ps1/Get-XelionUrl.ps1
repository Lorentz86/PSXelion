function Get-XelionUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Adds the renew to the url")]
        [switch]$renew,

        [Parameter(Mandatory=$false, HelpMessage="Customize the addressables url separated by a comma. For example SortBy, ")]
        [hashtable]$Addressables,

        [Parameter(Mandatory=$false)]
        [string]$Paging
    )
    
    # Default URL
    try {
        $default = $Script:XelionConfig["XelionUri"]
    }
    catch {
        Write-Error "Failed to get default URL. Import XelionConfig using Import-XelionAuthToken or renew the token using Get-XelionAuthToken: $_"
        return
    }

    # Renew URL
    if ($renew.IsPresent) {
        return "$default/me/renew"
    }

    # Paging
    $pagingUrl = ""
    if ($null -ne $Paging -and $Paging.Length -gt 0) {
        $pagingUrl = "$Paging&"
    }

    # Addressables URL
    if ($null -ne $Addressables -and $Addressables.Count -gt 0) {
        $urlList = [System.Collections.ArrayList]::new()
        $addressablesUri = "/addressables?"

        if ($Addressables.ContainsKey("SortBy")) {
            $SortByUrl = "order_by=" + $Addressables["SortBy"]
            $urlList.add($SortByUrl) | Out-Null
        }

        if ($Addressables.ContainsKey("Include")) {
            $includeUrl = "&include=" + ($Addressables["Include"] -join ",")
            $includeUrl = $includeUrl.replace("=,", "=")
            $urlList.add($includeUrl) | Out-Null
        }

        if ($Addressables.ContainsKey("Name")) {
            $nameUrl = "&name=" + $Addressables["Name"]
            $urlList.add($nameUrl) | Out-Null
        }

        if ($Addressables.ContainsKey("oid")) {
            $addressablesUri = "/addressables/"
            $oidUrl = $Addressables["oid"]
            $urlList.add($oidUrl) | Out-Null
        }

        if ($Addressables.ContainsKey("Filter")) {
            $filterUrl = "&where=obj_type=" + ($Addressables["Filter"] -join ",")
            $filterUrl = $filterUrl.replace("=,", "=")
            $urlList.add($filterUrl) | Out-Null
        }

        $defaultUrl = $default + $addressablesUri + $pagingUrl
        $generatedUrl = $urlList -join ""
        $finalUrl = $defaultUrl + $generatedUrl
        return $finalUrl
    }

    Write-Error "No valid parameters provided to generate URL."
}