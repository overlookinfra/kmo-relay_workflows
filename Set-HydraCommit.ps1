<# Write-Output "Getting Docebo data:"
$jsonList = (Relay-Interface get -p '{.EventListData}')

$data = $jsonList | ConvertFrom-Json

Write-Output "Converted back to PSobject list:"
Write-Output "$($data)"

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

$eventList+=$newEventB #>

Write-Output "Debug logging"
