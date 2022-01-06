# Get some mock data from Docebo
Write-Output "Getting data from Docebo:"
$uri = "https://training.puppet.com/course/v1/courses"
Write-Output "Using uri: $uri"
Write-Output "Setting up auth header"
$headers = @{Authorization = "Bearer $env:DoceboToken"}
    
$response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

$filteredList = $response.data.items | Where-Object {$_.last_update -lt "2021-11-15 00:00:00"}

Write-Output "Filtered list: "
Write-Output $filteredList

Write-Output "Printing directory"
Get-Location

$manifestTemplate = @'
---
stack: legacyclass
tf_action: apply
owner: Alex Williamson
owner_email: alex.williamson@puppet.com
region: us-east-1
days_needed: 1
department: EDU
tf_parameters:
  puppet_class_type: GSWP
  student_machine_count: '3'
'@

git clone https://$($env:GithubPAT)@github.com/awilliamson-puppet/puppetlabs/courseware-lms-nextgen-hydra.git

Set-Location courseware-lms-nextgen-hydra

git checkout -b aw-test-gswp 

$manifestTemplate | Out-File manifest.yaml

Get-Contents manifest.yaml

git add --all
