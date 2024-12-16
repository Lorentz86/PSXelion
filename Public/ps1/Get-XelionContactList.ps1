function Get-XelionContactList{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Filter what contacts you want to have. Can have more then one. Leave empty to receive all of them but I do not advice this course of action. Can take a while to generate. ")]
        [ValidateSet("Person","Organisation","X1Object","UnknownAddressable")]
        [string[]]$Type,

        [Parameter(Mandatory=$false, HelpMessage="Raw Contact information so you can make your own list")]
        [switch]$Raw,

        [Parameter(Mandatory=$false, HelpMessage="Get the private, business or (default) both contact information.")]
        [ValidateSet("Private","Business","Both")]
        [string]$Include="Both",

        [Parameter(Mandatory=$true, HelpMessage="The preconfigured structures are csv and json. If you want to create your own, choose raw")]
        [ValidateSet("Raw","csv","Json")]
        [string]$Format="json"

    )
    
    try{
        if($Format -match "Raw"){
            if(1 -ge $type.Count){
                Write-Information -MessageData "Getting all contacts. Can take a long time."
                $AllContacs = Get-XelionAddressables -SortBy Name
                return $AllContacs
            }
            $AllContacs = Get-XelionAddressables -Filter $Type
            foreach($XelionContact in $AllContacts){
                
            }
        }
    }
    catch{
        Write-Error "Could not generate list: $_"
    }
    
}