Write-Output "Standard write output"

$obj = New-[PSCustomObject]@{
    Name = "ObjectName"
    NullProp = $null 
    Empty = ""
}

Write-Output "Testing logging $obj"