function Get-XelionContactList{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Filter what contacts you want to have. Can have more then one. Leave empty to receive all of them but I do not advice this course of action. Can take a while to generate. ")]
        [ValidateSet("Person","Organisation","X1Object","UnknownAddressable")]
        [string[]]$Type,

        [Parameter(Mandatory=$false, HelpMessage="Raw Contact information so you can make your own list")]
        [switch]$Raw

    )
    
    try{
        if($raw.IsPresent){
            if(1 -ge $type.Count){
                Write-Information -MessageData "Getting all contacts. Can take a long time."
                $AllContacs = Get-XelionAddressables -SortBy Name
                return $AllContacs
            }
            $Info = Get-XelionAddressables -Filter $Type
            return $Info
        }
    }
    catch{
        Write-Error "Could not generate list: $_"
    }
    
}