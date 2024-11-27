<#
.SYNOPSIS
    Exports the Xelion authentication configuration to a file.

.DESCRIPTION
    This function saves the current Xelion configuration, including the authentication token, to an XML file
    in the user's AppData directory.

.EXAMPLE
    Export-XelionAuthConfig
#>
function Export-XelionAuthConfig {
    [CmdletBinding()]
    param()

    try {
        # Check if the authentication token is present
        if (-not $script:XelionConfig["Authtoken"] -or $script:XelionConfig["Authtoken"] -eq "") {
            Write-Error -Message "No Authtoken present. Please run Get-XelionAuthToken to generate a new token."
            return
        }

        # Define the path to the configuration file
        $ConfigPath = Join-Path $env:APPDATA -ChildPath "PSXelion"
        $ConfigFile = Join-Path $ConfigPath -ChildPath "XelionConfig.xml"

        # Ensure the configuration directory exists
        if (-not (Test-Path -Path $ConfigPath)) {
            New-Item -Path $ConfigPath -ItemType Directory -Force
        }

        # Create or overwrite the configuration file
        New-Item -Path $ConfigFile -ItemType File -Force

        # Export the configuration to the XML file
        $script:XelionConfig | Export-Clixml -Path $ConfigFile -Force
    }
    catch {
        Write-Error "Failed to save Xelion config file: $_"
    }
}