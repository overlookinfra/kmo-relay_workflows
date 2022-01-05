Write-Output "Fetching event list export"

$eventList = (Relay-Interface get -p "${outputs.'Export-Docebo-Events'.'EventListExport'}")

Write-Output $eventList 

Write-Output "eventList is type $eventList.GetType()"