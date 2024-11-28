# Import Functions
$PublicFunctions  = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue -Recurse)
$PrivateFunctions = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue -Recurse)

Write-Information -MessageData "Test"

Foreach ($Module in ($PublicFunctions + $PrivateFunctions)) {
    try {
        # Write-Information -MessageData "Importing $($Module.Basename)"
        "Importing $($Module.Basename)" | Out-File -FilePath "C:\temp\PSxelion.txt" -Append
        . $Module.FullName

        $Module.FullName | Out-File -FilePath "C:\temp\PSxelion.txt" -Append
    }
    Catch {
        Write-Error -Message "Failed to import function $($Module.FullName): $_"
    }
}

# Export only public functions
$PublicFunctionNames = $PublicFunctions.Basename
Export-ModuleMember -Function $PublicFunctionNames -Alias *