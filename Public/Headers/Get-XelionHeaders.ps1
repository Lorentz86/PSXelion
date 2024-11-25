function Get-XelionHeaders {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, HelpMessage="Add additional headers, for example Encoding")]
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