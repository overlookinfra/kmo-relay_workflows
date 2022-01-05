Write-Output "Starting"

Write-Output "Setting up form data"
$form = @{
    client_id = $($env:DoceboKey)
    client_secret = $($env:DoceboSecret)
    grant_type = 'password'
    scope = 'api'
    username = $($env:DoceboUsername)
    password = $($env:DoceboPassword)
}

$uri = "https://training.puppet.com/oauth2/token"

Write-Output "Using Docebo URI: $($uri)"

$getTokenResponse = Invoke-WebRequest -Uri $uri -Method Post -Form $form

Write-Output "Setting access token output value"

Relay-Interface ouput set -k DoceboToken -v $($getTokenResponse.access_token)