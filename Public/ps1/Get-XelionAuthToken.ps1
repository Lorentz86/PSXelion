<#
.SYNOPSIS
    Retrieves an authentication token from the Xelion API.

.DESCRIPTION
    This function logs into the Xelion API using provided credentials and retrieves an authentication token.
    It also sets up the Xelion configuration for further API calls.

.PARAMETER Credentials
    Secure string containing the API username and password.

.PARAMETER Hostname
    The hostname of the Xelion tenant (e.g., exampleCompany.xelion.com).

.PARAMETER Tennant
    Name of the tenant if in a multitenant setup. For single tenants leave empty. Default is master

.PARAMETER Save
    Save the Xelion Authtoken in a XelionConfig file in $env:Appdata in the folder PSXelion.

.EXAMPLE
    $creds = Get-Credential
    Get-XelionAuthToken -Credentials $creds -Hostname "exampleCompany.xelion.com"
    Get-XelionAuthToken -Credentials $creds -Hostname "exampleCompany.xelion.com -save"
#>
function Get-XelionAuthToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Credentials to connect to the Xelion API")]
        [pscredential]$Credentials,

        [Parameter(Mandatory=$true, HelpMessage="Hostname of the Xelion tenant (e.g., exampleCompany.xelion.com)")]
        [string]$Hostname,

        [Parameter(Mandatory=$false, HelpMessage="Name of the tenant if in a multitenant setup. For single tenants leave empty. Default is master")]
        [string]$Tennant="master",

        [Parameter(Mandatory=$false, HelpMessage="Save the Xelion Authtoken in a XelionConfig file in `$env:Appdata in the folder PSXelion.")]
        [switch]$Save
    )

    try {
        # Construct the user space identifier
        $Userspace = "ApiUser_$(hostname)"

        # Construct the login URI
        $loginUri = "/me/login"
        $Uri = "https://$Hostname/api/v1/$Tennant$loginUri"

        # Prepare the request body
        $body = @{
            userName = $Credentials.userName
            password = $Credentials.password | ConvertFrom-SecureString -AsPlainText
            userSpace = $Userspace
        } | ConvertTo-Json

        # Send the login request
        $Response = Invoke-RestMethod -Uri $Uri -Method Post -Body $body -ContentType "application/json"

        # Store the authentication details in a script-scoped variable
        $script:XelionConfig = @{
            XelionUri = "https://$Hostname/api/v1/$Tennant"
            XelionTenant = $Tennant
            Authtoken = $Response.authentication | ConvertTo-SecureString -AsPlainText
            renewalToken = $Response.renewalToken | ConvertTo-SecureString -AsPlainText
            validUntil = $Response.validUntil
        }

        # Save the Xelion config to a file. 
        if($save){
            Export-XelionAuthConfig
        }

        Write-Information  -MessageData "Authorisation token will expire after: $($script:XelionConfig['validUntil'])"
    }
    catch {
        Write-Error "Failed to retrieve Xelion authentication token: $_"
    }
}