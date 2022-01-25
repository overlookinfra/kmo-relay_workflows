Write-Output "Standard write output"

$obj = [PSCustomObject] @{
    Name = "ObjectName"
    NullProp = $null 
    Empty = ""
}

Write-Output "Testing logging Name: $($obj.Name)"

Write-Output "Testing logging Name: $($obj.NullProp)"

Write-Output "Testing logging Name: $($obj.Empty)"