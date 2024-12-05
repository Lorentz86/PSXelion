function Get-XelionPerson{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Sort by name, mru (Most Recent Used). Default is Name")]
        [ValidateSet("Name","mru")]
        [string]$SortBy="Name",

        [Parameter(Mandatory=$false, HelpMessage="Include user objects as status or employment seperated by a comma")]
        [ValidateSet("status", "employment","keywords")]
        [string[]]$Include,

        [Parameter(Mandatory=$false, HelpMessage="Leave empty to generate a list of al Persons. Give a name ")]
        [string]$Name
    )

    $Persons = @{}
    
    # Adding the SortBy values to the SortBy Key
    $Persons["SortBy"] = $SortBy

    # Adding the In
    if($Include){$Persons["Include"] = $Include}
    if($Name){$Persons["Name"] = $Name}

    # Generate the URL for Addressables    
    $url = Get-XelionUrl -Persons $Persons
    Write-Information -MessageData "Current url: $url"

    # Get the headers
    $headers = Get-XelionHeaders

    # First run to get started
    $Result = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -ContentType "application/json"
    $arrayList = [System.Collections.ArrayList]::new()
    $PersonsList = ConvertFrom-XelionObject -Response $Result
    $arrayList.Add($PersonsList)

    # get all the adressables
    while($true){
        $oid = $PersonsList.oid | Select-Object -Last 1
        $newuri = Get-XelionUrl -Persons $Persons -Paging $oid
        $Result = Invoke-WebRequest -Uri $newuri -Method Get -Headers $headers -ContentType "application/json"
        $PersonsList = ConvertFrom-XelionObject -Response $Result
        if(!$PersonsList){break}
        $arrayList.Add($PersonsList)
    }
    return $arrayList
}