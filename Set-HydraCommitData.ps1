Write-Output "Fetching event list export string"

$eventListString = (Relay-Interface get -p '{.EventListData}')

Write-Output "eventListString:"

Write-Output $eventListString

foreach ($event in $eventListString) {
    Write-Output "Checking for event item:"
    Write-Output $event
}