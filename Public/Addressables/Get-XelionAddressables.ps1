function Get-XelionAddressables{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Sort by name, mru (Most Recent Used)")]
        [ValidateSet("Name","mru")]
        [string]$SortBy="Name",

        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment seperated by a comma")]
        [ValidateSet("status", "employment")]
        [string[]]$Include
    )

    # Making the Addressables hashtable
    $Addressables = @{}
    
    # Adding the SortBy values to the SortBy Key
    $Addressables["SortBy"] = $SortBy

    # Adding the In
    if($Include){$Addressables["Include"] = $Include}

    # Generate the URL for Addressables    
    $url = Get-XelionUrl -Addressables $Addressables
   
    # Get the headers
    $headers = Get-XelionHeaders

    # First run to get started
    $Result = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -ContentType "application/json"
    $arrayList = [System.Collections.ArrayList]::new()
    $datasetJson = $Result.Content | ConvertFrom-Json
    $datasetObjects = $datasetJson.data.object
    $arrayList.Add($datasetObjects)

    # get all the adressables
    $limit = 0
    while($limit -lt 10){
        $limit++
        $oid = $datasetObjects.oid | Select-Object -Last 1
        $newuri = Get-XelionUrl -Addressables $Addressables -Paging $oid
        $Result = Invoke-WebRequest -Uri $newuri -Method Get -Headers $headers -ContentType "application/json"
        $datasetJson = $Result.Content | ConvertFrom-Json
        $datasetObjects = $datasetJson.data.object
        $arrayList.Add($datasetObjects)
    }
}