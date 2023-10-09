Install-Module Microsoft.Graph -Force
Import-Module Microsoft.Graph

$tenantId = $env:tenantId
$apiPrincipalId = $env:principalId

$graphClientId = $env:graphClientId
$graphClientSecret = $env:graphClientSecret

$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $graphClientId
    Client_Secret = $graphClientSecret
}
 
$connection = Invoke-RestMethod `
    -Uri https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token `
    -Method POST `
    -Body $body
 
$token = $connection.access_token | ConvertTo-SecureString -AsPlainText -Force
Connect-MgGraph -AccessToken $token -NoWelcome

$exists = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $apiPrincipalId
if (!$exists) {
    Write-Host "Creating new app role assignment for ${apiPrincipalId}"
    $appRegistration = Get-MgServicePrincipal -Filter "DisplayName eq 'api2api-test'"
    $resourceId = $appRegistration.Id
    $appRoleId = ($appRegistration.AppRoles | Where-Object {$_.Value -eq 'app_role_access_mi' }).Id

    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $apiPrincipalId -PrincipalId $apiPrincipalId -ResourceId $resourceId -AppRoleId $appRoleId
} else {
    Write-Host "App role assignment already existed for ${apiPrincipalId}"
}

# Set-Item -Path env:principalId -Value 1234