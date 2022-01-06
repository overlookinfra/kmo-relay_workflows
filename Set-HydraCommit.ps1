# Get some mock data from Docebo
Write-Output "Getting data from Docebo:"
$uri = "https://training.puppet.com/course/v1/courses"
Write-Output "Using uri: $($uri)"
Write-Output "Setting up auth header"
$headers = @{Authorization = "Bearer $($env:DoceboToken)"}
    
$response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

Write-Output "Returned unfiltered data: "
Write-Output $response.data.items

$filteredList = $response.data.items | Where-Object {$_.last_update -lt "2021-11-15 00:00:00"}

Write-Output "Filtered list: "
Write-Output $filteredList

