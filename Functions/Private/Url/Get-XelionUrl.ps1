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
    $default = $Script:XelionConfig["XelionUri"]

    # Renew URl Start
    if ($renew.IsPresent){
        $loginUri = "/me/renew"
        return $default + $loginUri
    }
    # Renew End

    # Addressables URL Start
    if($Addressables){
        $addressablesUri = "/addressables?"
        
        # SortBy Hashtable
        $SortBy = "SortBy"
        $SortByUrl = "order_by="
        if($addressables[$SortBy]){
            $addressablesUri = $addressablesUri + "$SortBy="+$addressables[$SortBy]
        }
        
        # Include hastable
        if($Addressables[$Include]){
            $Include = "Include"
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
    # Addressables URL End
}