$global:workArray = @()
$global:validSessions = @()
$global:validCourses = @()

Write-Output "Debug control variable is $env:DEBUG"
Write-Output "Forecast days interval is $env:FORECAST"
Write-Output "Seats setting is: $($env:SEATS)"

function Confirm-SessionDateWindow {
    [CmdletBinding()]
    param (
        [Parameter()]
        [DateTime]
        $Date
    )

    $currentDate = Get-Date
    $forecastInterval = New-TimeSpan -Days $env:FORECAST
    $forecastDate = $currentDate + $forecastInterval

    if ($Date -ge $currentDate -and $Date -le $forecastDate) {
        return $true
    }

    else {
        return $false
    }
    
}

function Get-ValidCourses {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $AuthToken
    )
    Write-Output "Setting up auth header for get all courses"
    $headers = @{Authorization = "Bearer $AuthToken"}

    $allCourses = Invoke-RestMethod -Uri 'https://training.puppet.com/course/v1/courses?page_size=5000' -Method GET -Headers $headers
    Write-Output "Retrieved a total of $($allCourses.data.items.Count) courses"

    foreach ($course in $allCourses.data.items) {
        if (($course.code -like "*GSWP*") -or ($course.code -like "*PRAC*") -or ($course.code -like "*Workshop*")) {
            Write-Output "Adding course with code $($course.code) to valid course array"
            $global:validCourses+=$course
        }
    }
}

function Get-ValidSessions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $AuthToken
    )

    Write-Output "Setting up auth header"
    $headers = @{Authorization = "Bearer $AuthToken"}
    $combined = @()

    foreach ($course in $global:validCourses) {
        Write-Output "Adding sessions for course $($course.name) to combined session list for pruning"
        $courseSessions = Invoke-RestMethod -uri "https://training.puppet.com/course/v1/courses/$($course.id)/sessions?page_size=5000" -Headers $headers -Method Get
        Write-Output "Got $($courseSessions.data.items.Count) sessions for course code $($course.code) - adding to array"
        $combined+=$courseSessions.data.items
    }

    Write-Output "Evaluating start date for total sessions $($combined.Count)"

    foreach ($session in $combined) {
        if ($session.date_start) {           
            Write-Output "Working on Session ID $($session.id) with Start Date $($session.date_start)"
            if (Confirm-SessionDateWindow([DateTime]$session.date_start)) {
                $global:validSessions+=$session
            }
            else {
                Write-Output "Session ID $($session.id) not valid for date window"
            }
        } else {
            Write-Output "Sessions ID $($session.id) has no start date"
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
        $GithubPAT,
        [Parameter()]
        [String]
        $AuthToken
    )
    Write-Output "Setting up auth header for session data"
    $headers = @{Authorization = "Bearer $AuthToken"}

    foreach ($session in $SessionList) {
        $branchID = "R2H-$($session.uid_session)"
        $branchID = $branchID.ToLower()
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

        Write-Output "Getting session data to lookup instructor name and email"

        $sessionData = Invoke-RestMethod -Method Get -Uri "https://training.puppet.com/course/v1/sessions/$($session.id)" -Headers $headers

        Write-Output "Instructor data: $($sessionData.data.instructors | Out-String)"
        Write-Output "First instructor in array to be used: $($sessionData.data.instructors[0].firstname) $($sessionData.data.instructors[0].lastname)  $($sessionData.data.instructors[0].username)"

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

        $region = switch -Wildcard ($($session.name)) {
            '*APAC*' {'ap-southeast-1'}
            '*Australia*' {'ap-southeast-1'}
            '*EMEA*' {'eu-central-1'}
            '*US (East)*' {'us-east-1'}
            '*US (West)*' {'us-west-2'}
            Default {'us-east-1'}
        }

        Write-Output "Seats"

        $adjustedSeats = $($env:SEATS)
        $fullName = $($sessionData.data.instructors[0].firstname) + " " + $($sessionData.data.instructors[0].lastname)
        Write-Output "File manip"
        ((Get-Content -path manifest.yaml -Raw) -replace '<CLASSTYPE>', $classType) | Set-Content -Path manifest.yaml
        ((Get-Content -path manifest.yaml -Raw) -replace '<STUDENTCOUNT>', $adjustedSeats) | Set-Content -Path manifest.yaml
        ((Get-Content -path manifest.yaml -Raw) -replace '<LEGACY_CLASS_ID>', $legacyClass) | Set-Content -Path manifest.yaml
        ((Get-Content -path manifest.yaml -Raw) -replace '<REGION>', $region) | Set-Content -Path manifest.yaml
        Write-Output "Instructor name concat"
        ((Get-Content -path manifest.yaml -Raw) -replace '<NAME>', $fullName) | Set-Content -Path manifest.yaml
        Write-Output "Email"
        ((Get-Content -path manifest.yaml -Raw) -replace '<EMAIL>', $($sessionData.data.instructors[0].username)) | Set-Content -Path manifest.yaml


        Write-Output "Adjusted manifest.yaml data:"
        $adjustedManifest = Get-Content manifest.yaml -Raw
        Write-Output $adjustedManifest

        if ($env:DEBUG -ne "noop") {
            Write-Output "DEBUG control not set to noop - entering git add and commit block"
            git add --all
            git commit -m "Provision environment from Relay: session id: $($session.id) uid: $($session.uid_session)"
            git push origin $branchID
        } 

        $session | Add-Member -MemberType NoteProperty -Name 'HydraBranch' -Value $branchID

        $global:workArray+=$session
    }

}

$manifestTemplate = @"
---
stack: <CLASSTYPE>
tf_action: apply
owner: <NAME>
owner_email: <EMAIL>
region: <REGION>
days_needed: 12
department: EDU
tf_parameters:
    <LEGACY_CLASS_ID>
    student_machine_count: '<STUDENTCOUNT>'
"@
Write-Output "Getting all courses"
Get-ValidCourses -AuthToken $env:DoceboToken

Write-Output "Getting all valid sessions for valid courses"
Get-ValidSessions -AuthToken $env:DoceboToken 

git config --global user.email "eduteam@puppetlabs.com"
git config --global user.name "puppetlabs-edu-api"

Write-Output "Setting base working directory location"
Set-Location /

Write-Output "Cloning hydra base repo"
git clone "https://puppetlabs-edu-api:$($env:GithubPAT)@github.com/puppetlabs/courseware-lms-nextgen-hydra.git"

Write-Output "Setting working directory to hydra repo"
Set-Location courseware-lms-nextgen-hydra

Set-HydraCommits -SessionList $global:validSessions -AuthToken $env:DoceboToken

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
