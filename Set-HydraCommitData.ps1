Write-Output "Fetching event list export string"

$eventListString = (Relay-Interface get -p '{.EventListData}')

Write-Output "eventListString:"

Write-Output $eventListString

foreach ($event in $eventListString) {
    Write-Output "Checking for event item:"
    Write-Output $event
}

$eventListObjects = $eventListString | ConvertFrom-Json

foreach ($event in $eventListObjects) {
    Write-Output "Event object list:"
    Write-Output $event
}