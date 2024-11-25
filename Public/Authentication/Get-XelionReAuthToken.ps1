<#
.SYNOPSIS
    Renews the authentication token for the Xelion API.

.DESCRIPTION
    This function uses the renewal token to obtain a new authentication token from the Xelion API.
    It updates the Xelion configuration with the new tokens and their validity period.

.EXAMPLE
    Get-XelionReAuthToken
#>
function Get-XelionReAuthToken {
    [CmdletBinding()]
    param()

    try {
        # Construct the renewal URI
        $loginUri = "/me/renew"
        $Uri = $script:XelionConfig["XelionUri"] + $loginUri

        # Prepare the request body and headers
        $body = $script:XelionConfig["renewalToken"] | ConvertFrom-SecureString
        $headers = Get-XelionHeaders

        # Send the renewal request
        $response = Invoke-RestMethod -Method Post -Uri $Uri -Body $body -Headers $headers -ContentType "application/json"

        # Update the Xelion configuration with the new tokens and validity period
        $script:XelionConfig = @{
            XelionUri = $script:XelionConfig["XelionUri"]
            XelionTenant = $script:XelionConfig["XelionTenant"]
            Authtoken = $response.authentication | ConvertTo-SecureString -AsPlainText
            renewalToken = $response.renewalToken | ConvertTo-SecureString -AsPlainText
            validUntil = $response.validUntil
        }
    }
    catch {
        Write-Error "Failed to renew Xelion authentication token: $_"
    }
}