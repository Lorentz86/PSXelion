function Get-XelionUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Adds the renew to the url")]
        [switch]$renew,

        [Parameter(Mandatory=$false, HelpMessage="Customize the addressables url seperated by a comma. For example SortBy, ")]
        [hashtable]$Addressables,

        [Parameter(Mandatory=$false, HelpMessage="Object ID (oid) of the last object")]
        [string]$Paging

    )
    
    # Default URL
    try{
        $default = $Script:XelionConfig["XelionUri"]
    }
    catch{
        Write-Error "Failed to get get default url. Import Xelionconfig using Import-XelionAuthToken or renew the token using Get-XelionAuthToken: $_"
    }

    try{
            # Renew URl Start
    if ($renew.IsPresent){
        $loginUri = "/me/renew"
        return $default + $loginUri
    }
    # Renew End
    }
    catch{
        Write-Error "Failed to generate renew url: $_"
    }


    try {
            # Addressables URL Start
        if($Addressables){
            $addressablesUri = "/addressables?"
            
            # SortBy Hashtable
            $SortBy = "SortBy"
            if($addressables.ContainsKey($SortBy)){
                $SortByUrl = "order_by="
                $SortByUrl = $SortByUrl + $addressables[$SortBy]
            }
            
            # Include hastable
            $Include = "Include"
            if($Addressables.ContainsKey($Include)){
                $includeurl = "&include="
                $IncludeArray = $Addressables[$Include] | Select-Object -Unique
                
                foreach($Value in $IncludeArray){
                    $includeurl=$includeurl + ",$value"
                }
                $includeurl = $includeurl.replace("=,","=")
            }
            
            # if paging is in use
            if($paging){$pagingurl = Get-XelionPagingUrl -Paging $Paging}
            
            $finalurl = $default + $addressablesUri + $SortByUrl + $includeurl + $pagingurl
            return $finalurl
        }
    }
    # Addressables URL End
    catch {
        Write-Error "Failed to generate Addressable url: $_"
    }

}