Write-Output "Standard write output"

$obj = [PSCustomObject] @{
    Name = "ObjectName"
    NullProp = $null 
    Empty = ""
}

Write-Output "Testing logging $($obj)"