#   Import Functions
$Public = @(Get-Childitem -path "$PSScriptRoot\Public\Authentication\*.ps1" -ErrorAction SilentlyContinue -Recurse)

Foreach ($Module in $Public ){
    try{
        .$Module.fullName
    }
    Catch{
         Write-Error -Message "Failed to import function $($import.fullName): $_"
    }
}

Export-ModuleMember -Function $Public.basename -Alias *