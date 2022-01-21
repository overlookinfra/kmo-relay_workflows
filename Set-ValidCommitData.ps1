$global:workArray = @()
$global:validSessions = @()

function Confirm-SessionDateWindow {
    [CmdletBinding()]
    param (
        [Parameter()]
        [DateTime]
        $Date
    )

    $currentDate = Get-Date
    $forecastInterval = New-TimeSpan -Days 10
    $forecastDate = $currentDate + $forecastInterval

    if ($Date -ge $currentDate -and $Date -le $forecastDate) {
        return $true
    }

    else {
        return $false
    }
    
}

function Get-ValidSessions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $AuthToken
    )
    $global:validSessions = @()
    Write-Output "Setting up auth header"
    $headers = @{Authorization = "Bearer $AuthToken"}

    $gswpSessions = Invoke-RestMethod -uri 'https://training.puppet.com/course/v1/courses/3/sessions' -Headers $headers -Method Get
    Write-Output "gswpSessions:"
    Write-Output $gswpSessions.data.items 
    #TODO: add endpoints for other course types
    # $pracSessions = Invoke-RestMethod -uri 'https://'
    # workshopSessions = Invoke-RestMethod -uri 'https://'

    foreach ($session in $gswpSessions.data.items) {
        if (Confirm-SessionDateWindow([DateTime]$session.date_start)) {
            $global:validSessions+=$session
        }
        else {
            Write-Output "Session with name: $($session.name) and start date $($session.date_start) not valid for session window"
        }
    }

}

function Set-HydraCommits {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Array]
        $SessionList,
        [Parameter()]
        [String]
        $GithubPAT
    )

    foreach ($session in $SessionList) {
        $branchID = "R2H-$($session.uid_session)"
        Write-Output "Working on session item $($session.name)"
        Write-Output "Creating branch: $branchID"
        git checkout -b $branchID 
        Write-Output "Removing manifest.yaml if it exists"
        if (Test-Path manifest.yaml) {
            Remove-Item manifest.yaml
        }
        Write-Output "Adding manifest template"
        $manifestTemplate >> manifest.yaml
        git status 
        Write-Output "Adjusting manifest file values:"

        $classType = switch -Wildcard ($($session.name)) {
            'Getting Started*' {'legacyclass'}
            'Puppet Practitioner*' {'legacyclass'}
            'Upgrade*' {'peupgradeworkshop'}
        }

        $legacyClass = switch -Wildcard ($($session.name)) {
            'Getting Started*' {'puppet_class_type: GSWP'}
            'Puppet Practitioner*' {'puppet_class_type: PRAC'}
            'Upgrade*' {''}
        }

        $region = "us-east-1"

        $adjustedSeats = 0 + [Int]$session.enrolled

        ((Get-Content -path manifest.yaml -Raw) -replace '<CLASSTYPE>', $classType) | Set-Content -Path manifest.yaml
        ((Get-Content -path manifest.yaml -Raw) -replace '<STUDENTCOUNT>', $($adjustedSeats)) | Set-Content -Path manifest.yaml
        ((Get-Content -path manifest.yaml -Raw) -replace '<LEGACY_CLASS_ID>', $legacyClass) | Set-Content -Path manifest.yaml
        ((Get-Content -path manifest.yaml -Raw) -replace '<REGION>', $region) | Set-Content -Path manifest.yaml

        Write-Output "Adjusted manifest.yaml data:"
        $adjustedManifest = Get-Content manifest.yaml -Raw
        Write-Output $adjustedManifest

        git add --all
        git commit -m "Provision environment from Relay: session id: $($session.id) uid: $($session.uid_session)"
        git push origin $branchID

        $session | Add-Member -MemberType NoteProperty -Name 'HydraBranch' -Value $branchID

        $global:workArray+=$session
    }

}

$manifestTemplate = @"
---
stack: <CLASSTYPE>
tf_action: apply
owner: puppetlabs-edu-api
owner_email: eduteam@puppetlabs.com
region: <REGION>
days_needed: 7
department: EDU
tf_parameters:
    <LEGACY_CLASS_ID>
    student_machine_count: '<STUDENTCOUNT>'
"@

Get-ValidSessions -AuthToken $env:DoceboToken -InformationAction Continue

git config --global user.email "eduteam@puppetlabs.com"
git config --global user.name "puppetlabs-edu-api"

Write-Output "Setting base working directory location"
Set-Location /

Write-Output "Cloning hydra base repo"
git clone "https://puppetlabs-edu-api:$($env:GithubPAT)@github.com/puppetlabs/courseware-lms-nextgen-hydra.git"

Write-Output "Setting working directory to hydra repo"
Set-Location courseware-lms-nextgen-hydra

Set-HydraCommits -SessionList $global:validSessions -InformationAction Continue

$global:workArray  | Format-Table -Property name, id, uid_session, HydraBranch, date_start 
Write-Output "Printing table"
$outputTable = $global:workArray | Format-Table -Property name, id, uid_session, HydraBranch, date_start  -AutoSize | Out-String
Write-Output $outputTable

$formatBlock = @"
Docebo Sessions sent to Hydra2:
``````
$($outputTable)
``````
"@

Relay-Interface output set -k WorkLog -v $formatBlock