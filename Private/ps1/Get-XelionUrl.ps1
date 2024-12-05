function Get-XelionUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Adds the renew to the url")]
        [switch]$renew,

        [Parameter(Mandatory=$false, HelpMessage="Customize the addressables url seperated by a comma. For example SortBy, ")]
        [hashtable]$Addressables,

        [Parameter(Mandatory=$false, HelpMessage="Object ID (oid) of the last object")]
        [string]$Paging,

        [Parameter(Mandatory=$false, HelpMessage="Customize the Persons url seperated by a comma. For example SortBy, ")]
        [hashtable]$Persons

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
        if($Addressables.count -ge 1){
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
    catch {
        Write-Error "Failed to generate Addressable url: $_"
    }
        # Addressables URL End

        # Persons URL Start
    try {
        if($Persons.count -ge 1){
            $personsUri = "/addressables/persons?"
            
            # SortBy Hashtable
            $SortBy = "SortBy"
            if($Persons.ContainsKey($SortBy)){
                $SortByUrl = "order_by="
                $SortByUrl = $SortByUrl + $Persons[$SortBy]
            }
            
            # Include hastable
            $Include = "Include"
            if($Persons.ContainsKey($Include)){
                $includeurl = "&include="
                $IncludeArray = $Persons[$Include] | Select-Object -Unique
                
                foreach($Value in $IncludeArray){
                    $includeurl=$includeurl + ",$value"
                }
                $includeurl = $includeurl.replace("=,","=")
            }
            
            # name hashtable
            $Name = "Name"
            if($Persons.ContainsKey($Name)){
                $nameurl = "&name=" + $Persons[$Name]
            }

            # if paging is in use
            if($paging){$pagingurl = Get-XelionPagingUrl -Paging $Paging}
            
            $finalurl = $default + $personsUri + $SortByUrl + $includeurl + $nameurl + $pagingurl
            return $finalurl
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }

    # Persons URL End
    


}