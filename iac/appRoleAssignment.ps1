$tenantId = $env:tenantId
$apiPrincipalId = $env:principalId
$appRegistrationId = $env:appRegistrationId
$roleToSet = "server-api"

# Graph setup
$graphToken = $(Get-AzAccessToken -Tenant $tenantId -ResourceUrl "https://graph.microsoft.com").Token
$graphUrl = "https://graph.microsoft.com/v1.0/servicePrincipals"
$headers = @{Authorization = "Bearer $graphToken"}

# App registration / getting custom role ids
$appRegistration = Invoke-RestMethod -Method "Get" -Uri "${graphUrl}/${appRegistrationId}" -Headers $headers
$appRoles = $appRegistration.appRoles
$appRoleId = ($appRoles | Where-Object {$_.Value -eq $roleToSet }).Id

# App role assignment
$appAssignments = Invoke-RestMethod -Method 'Get' -Uri "${graphUrl}/${apiPrincipalId}/appRoleAssignments" -Headers $headers

$exists = $appAssignments.value | Where-Object {$_.appRoleId -eq $appRoleId}

if ($exists) {
    Write-Host "App role assignment already existed for ${apiPrincipalId}"
} else {
    Write-Host "Creating new app role assignment for ${apiPrincipalId}"

    $body = @{
        principalId = $apiPrincipalId
        resourceId = $appRegistrationId
        appRoleId = $appRoleId
    } | ConvertTo-Json


    Invoke-RestMethod -Method "Post" -ContentType "application/json" -Uri "${graphUrl}/${apiPrincipalId}/appRoleAssignments" -Headers $headers -Body $body
}

# Set-Item -Path env:principalId -Value 1234