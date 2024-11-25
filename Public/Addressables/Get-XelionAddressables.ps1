function Get-XelionAddressables{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Sort by name, mru (Most Recent Used)")]
        [ValidateSet("Name","mru")]
        [string]$SortBy="Name",

        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment seperated by a comma")]
        [string[]]$Include,

        [Parameter(Mandatory=$false, HelpMessage="Compress the data  to gzip from the API server, default is `$false")]
        [ValidateSet($true,$false)]
        [System.Boolean]$Compress=$false
    )
    # Default link
    $addressablesUri = "/addressables?"
    
    # Include user objects
    $includeurl=""
    if($Include){
        $includeurl = "&include="
        foreach($item in $Include){
            switch($item){
                "status" {$includeurl = $includeurl + ",status"}
                "employment" {$includeurl = $includeurl + ",employment"}
            }          
        }
        $includeurl = $includeurl.replace("=,","=")
    }

    # Uribuilder
    $uri = $Script:XelionConfig['XelionUri'] + $addressablesUri + "order_by="+$SortBy + $includeurl

    # Headers
    if($Compress){
        $headers = Get-XelionHeaders -AddHeaders "Encoding"
    }
    else {
        $headers = Get-XelionHeaders
    }  

    $Result = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers -ContentType "application/json"
    
    # Convert json data to an array
    $arrayList = [System.Collections.ArrayList]::new()
    $datasetJson = $Result.Content | ConvertFrom-Json
    $datasetObjects = $datasetJson.data.object


    $datasetJson.data | Foreach-Object -ThrottleLimit 5 -Parallel {
      $object = [PSCustomObject]@{
        name = ""
      }
    }

    
    # Create a human readable array

}