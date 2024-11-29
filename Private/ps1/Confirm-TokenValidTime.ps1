<#
.SYNOPSIS
    Checks if the Xelion authentication token is still valid.

.DESCRIPTION
    This function compares the current UTC date and time with the token's valid until date and time
    to determine if the token is still valid.

.EXAMPLE
    $isTokenValid = Confirm-TokenValidTime
    if ($isTokenValid) {
        Write-Output "The token is still valid."
    } else {
        Write-Output "The token has expired."
    }
#>
function Confirm-TokenValidTime {
    try {
        # Get the current date and time in UTC
        $currentDate = Get-Date -AsUTC

        # Retrieve the token's valid until date and time from the configuration
        [datetime]$tokenValidUntil = $script:XelionConfig["validUntil"]

        # Compare the token's valid until date with the current date
        return $tokenValidUntil -gt $currentDate
    }
    catch {
        Write-Error "Failed to confirm token validity: $_"
        return $false
    }
}