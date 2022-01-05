Write-Output "Fetching event list export string"

$eventListString = (Relay-Interface get -p '{.EventListData}')

Write-Output "converting eventListString to JSON"

$eventListJson = $eventListString | ConvertTo-Json

foreach ($event in $eventListJson) {
    Write-Output $event
}