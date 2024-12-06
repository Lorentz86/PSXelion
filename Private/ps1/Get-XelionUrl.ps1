function Get-XelionUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Adds the renew to the url")]
        [switch]$renew,

        [Parameter(Mandatory=$false, HelpMessage="Customize the addressables url seperated by a comma. For example SortBy, ")]
        [hashtable]$Addressables,

        [Parameter(Mandatory=$false)]
        [string]$Paging
    )
    
    # Default URL
    try{
        $default = $Script:XelionConfig["XelionUri"]
    }
    catch{
        Write-Error "Failed to get get default url. Import Xelionconfig using Import-XelionAuthToken or renew the token using Get-XelionAuthToken: $_"
    }
            # Renew URl Start
    try{
        if ($renew.IsPresent){
            $loginUri = "/me/renew"
            return $default + $loginUri
        }

    }
    catch{
        Write-Error "Failed to generate renew url: $_"
    }
    # Renew End
    # Paging Begin
    try {
        if($paging.count -ge 1){
            $pagingUrl = $Paging + "&"
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    # Paging End


    # Addressables URL Start
    try {
        if($Addressables.count -ge 1){
            $addressablesUri = "/addressables?"

            # SortBy hash
            $SortBy = "SortBy"
            if($addressables.ContainsKey($SortBy)){
                $SortByUrl = "order_by="
                $SortByUrl = $SortByUrl + $addressables[$SortBy]
            }
            
            # Include hash
            $Include = "Include"
            if($Addressables.ContainsKey($Include)){
                $includeurl = "&include="
                $IncludeArray = $Addressables[$Include] | Select-Object -Unique
                
                foreach($Value in $IncludeArray){
                    $includeurl=$includeurl + ",$value"
                }
                $includeurl = $includeurl.replace("=,","=")
            }
            # Name hash
            $Name = "Name"
            if($Addressables.ContainsKey($Name)){
                $nameurl = "&name=" + $Addressables[$Name]
            }
            
            # OID hash
            $oid = "oid"
            if($Addressables.ContainsKey($oid)){
                $addressablesUri = "/addressables/"
                $oidurl = $Addressables[$oid]
            }
            
            # Filter hash
            $Filter = "Filter"
            if($Addressables.ContainsKey($Filter)){
                $filterUri = "&where=obj_type="
                $FilterArray = $Addressables[$Filter] | Select-Object -Unique
                
                foreach($Value in $FilterArray){
                    $filterUri=$filterUri + ",$value"
                }
                $filterUri = $filterUri.replace("=,","=")
            }
                     
            $finalurl = $default + $addressablesUri + $pagingUrl + $oidurl + $SortByUrl + $includeurl + $nameurl + $filterUri
            return $finalurl
        }
    }
    catch {
        Write-Error "Failed to generate Addressable url: $_"
    }
        # Addressables URL End
}