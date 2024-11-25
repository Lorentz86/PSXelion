<#
.SYNOPSIS
    Imports the Xelion authentication token configuration from a file.

.DESCRIPTION
    This function imports the Xelion configuration from an XML file stored in the user's AppData directory.
    It checks if the token is still valid and provides appropriate messages.

.EXAMPLE
    Import-XelionAuthToken
#>
function Import-XelionAuthToken {
    [CmdletBinding()]
    param()

    try {
        # Define the path to the configuration file
        $ConfigPath = Join-Path $env:APPDATA -ChildPath "PSXelion"
        $ConfigFile = Join-Path $ConfigPath -ChildPath "XelionConfig.xml"

        # Check if the configuration file exists
        if (-not (Test-Path -Path $ConfigFile)) {
            Write-Error -Message "No PSXelion config file found. Please run Get-XelionAuthToken with the -save parameter."
            return
        }

        # Import the configuration from the XML file
        $script:XelionConfig = Import-Clixml $ConfigFile

        # Check if the token is still valid
        $TokenValid = Confirm-TokenValidTime
        if ($TokenValid) {
            Write-Information -MessageData "Token is valid."
        } else {
            Write-Error -Message "Current authorization token is expired. Run Get-XelionAuthToken with the -save parameter to generate and save a new token."
            return
        }
    }
    catch {
        Write-Error "Failed to import Xelion config file: $_"
    }
}