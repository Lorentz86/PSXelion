<#
.SYNOPSIS
    Converts a Xelion object to a PowerShell object.

.DESCRIPTION
    This function takes a JSON response from a Xelion API call and converts it to a PowerShell object.
    It checks if the parameter is provided and includes a try-catch block for error handling.

.PARAMETER Response
    The JSON response from the Xelion API call.

.EXAMPLE
    $response = Invoke-RestMethod -Uri "https://api.xelion.com/v1/objects" -Method Get
    $result = ConvertFrom-XelionObject -Response $response
#>
function ConvertFrom-XelionObject {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Response
    )
    try {
        $datasetJson = $Response.Content | ConvertFrom-Json -Depth 10
        $Properties = ($datasetJson  | Get-Member | Where-Object -Property MemberType -Match NoteProperty).Name
        if("data" -notin $Properties) {
            Write-Information -MessageData "The json response does not contain a Data property, continue using the json object"
            $datasetObjects = $datasetJson.object
            $datasetNestedProperties = ($datasetObjects | Get-Member | Where-Object -Property MemberType -Match NoteProperty).Name
            $result = $datasetObjects | Select-Object -Property $datasetNestedProperties
            return $result
        }
        else{
            if($datasetJson.data.count -lt 1){
                Write-Information -MessageData "End of paging."
                return $false
            }
            $datasetObjects = $datasetJson.data.object
            $datasetNestedProperties = ($datasetObjects | Get-Member | Where-Object -Property MemberType -Match NoteProperty).Name
            $result = $datasetObjects | Select-Object -Property $datasetNestedProperties
            return $result
        }
    }
    catch {
        Write-Error "An error occurred while converting the Xelion object: $_"
    }
}