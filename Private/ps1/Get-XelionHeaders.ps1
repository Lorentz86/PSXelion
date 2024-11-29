<#
.SYNOPSIS
    Generates HTTP headers for Xelion API requests.

.DESCRIPTION
    This function generates the necessary HTTP headers for making requests to the Xelion API. It checks if the current authorization token is valid and includes it in the headers. Optionally, it can add additional headers such as "Accept-Encoding".

.PARAMETER AddHeaders
    An array of additional headers to include in the request. Currently supports "Encoding" to add "Accept-Encoding: gzip".

.EXAMPLE
    $headers = Get-XelionHeaders -AddHeaders "Encoding"
    This example generates headers including "Accept-Encoding: gzip".

.NOTES
    Ensure that the authorization token is valid before making API requests. If the token is expired, run Get-XelionAuthToken to generate a new token.
#>
function Get-XelionHeaders {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Add additional headers, for example Encoding")]
        [ValidateSet("Encoding")]
        [string[]]$AddHeaders
    )

    # Initializing headers
    $headers = @{}

    # Check if current token is valid
    $TokenValid = Confirm-TokenValidTime
    if ($TokenValid) {
        Write-Information -MessageData "Token is valid."
    } else {
        Write-Error -Message "Current authorization token is expired. Run Get-XelionAuthToken to generate a new token or add the -save parameter to save a new token."
        return
    }

    # Add headers
    try {
        foreach ($newheader in $AddHeaders) {
            if ($newheader -match "Encoding") {
                $headers["Accept-Encoding"] = "gzip"
            }
        }
        $headers["Authorization"] = "xelion " + ($script:XelionConfig["Authtoken"] | ConvertFrom-SecureString -AsPlainText)
    } catch {
        Write-Error -Message "Failed to generate headers: $_"
    }

    return $headers
}