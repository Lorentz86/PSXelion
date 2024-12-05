function Get-XelionAddressables{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Sort by name, mru (Most Recent Used). If mru is used include fields can onlby be status and employment.")]
        [ValidateSet("Name","mru")]
        [string]$SortBy="Name",

        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment seperated by a comma")]
        [ValidateSet("status", "employment","keywords")]
        [string[]]$Include,

        [Parameter(Mandatory=$false, HelpMessage="Leave empty to generate a list of al Persons. Use the name parameter to search a specific person")]
        [string]$Name
    )

    # Making the Addressables hashtable
    $Addressables = @{}
    
    # Adding the SortBy values to the SortBy Key
    $Addressables["SortBy"] = $SortBy

    # Adding the In
    if($Include){$Addressables["Include"] = $Include}
    if($Include){$Addressables["Name"] = $Name}

    # Generate the URL for Addressables    
    $url = Get-XelionUrl -Addressables $Addressables
    Write-Information -MessageData "Current url: $url"

    # Get the headers
    $headers = Get-XelionHeaders

    # First run to get started
    $Result = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -ContentType "application/json"
    $arrayList = [System.Collections.ArrayList]::new()
    $AddressablesList = ConvertFrom-XelionObject -Response $Result
    $arrayList.Add($AddressablesList)

    # get all the adressables
    while($true){
        $oid = $AddressablesList.oid | Select-Object -Last 1
        $newuri = Get-XelionUrl -Addressables $Addressables -Paging $oid
        $Result = Invoke-WebRequest -Uri $newuri -Method Get -Headers $headers -ContentType "application/json"
        $AddressablesList = ConvertFrom-XelionObject -Response $Result
        if(!$AddressablesList){break}
        $arrayList.Add($AddressablesList)
    }
    return $arrayList
}