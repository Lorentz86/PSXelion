function Get-XelionPagingUrl{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Response,

        [Parameter(Mandatory = $false)]
        [switch]$Before,

        [Parameter(Mandatory = $false)]
        [switch]$After
    )
    try {
        $datasetJson = $Response.Content | ConvertFrom-Json -Depth 10
        $metalinks = $datasetJson.meta.links
        if($Before.IsPresent){
            $url = $metalinks | Where-Object -Property rel -match "previous" | Select-Object -ExpandProperty href
            $beforeurl = $url.split("?") | Select-Object -last 1
            return $beforeurl
        }
        if($after.IsPresent){
            $url= $metalinks | Where-Object -Property rel -match "next" | Select-Object -ExpandProperty href
            $afterUrl = $url.split("?") | Select-Object -last 1
            return $afterUrl
        }
        else{
            throw "Choose the before or after parameter"
            return $false
        }
    }
    catch {
        Write-Error "Could not generate paging url: $($_.Exception.Message)"
    }

}