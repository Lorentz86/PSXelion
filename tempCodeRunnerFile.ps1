# Import Functions
$PublicFunctions  = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue -Recurse)
$PrivateFunctions = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue -Recurse)

Foreach ($Module in ($PublicFunctions + $PrivateFunctions)) {
    try {
        Write-Information -MessageData "Importing $($Module.Basename)"
        . $Module.FullName

        Write-Host $Module.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($Module.FullName): $_"
    }
}

# Export only public functions
$PublicFunctionNames = $PublicFunctions.Basename
Export-ModuleMember -Function $PublicFunctionNames -Alias *