# Mock data structure export

$eventList = @()

$tfParamsA = @{
    puppet_class_type = 'GSWP'
    student_machine_count = '3'
}

$newEventA = [PSCustomObject]@{
    stack = 'legacyclass'
    tf_action = 'apply'
    owner = 'Relay-Hydra-Integration'
    owner_email = 'alex.williamson@puppet.com'
    region = 'us-east-1'
    days_needed = '1'
    department = 'EDU'
    tf_parameters = $tfParamsA
}

$eventList+=$newEventA

$tfParamsB = @{
    puppet_class_type = 'GSWP'
    student_machine_count = '3'
}

$newEventB = [PSCustomObject]@{
    stack = 'legacyclass'
    tf_action = 'apply'
    owner = 'Relay-Hydra-Integration'
    owner_email = 'alex.williamson@puppet.com'
    region = 'us-east-1'
    days_needed = '1'
    department = 'EDU'
    tf_parameters = $tfParamsB
}

$eventList+=$newEventB

Write-Output $eventList

$eventListJson = $eventList | ConvertTo-Json

Write-Output $eventListJson

Relay-Interface output set -k EventListExport -v $eventListJson --json
