function Add-AppRoleAssignment {
    param(
        [string]$appRole,
        [Object]$existingAppRoles,
        [string]$graphUrl,
        [Object]$headers,
        [string]$principalId,
        [string]$appRegistrationId
    )

    $appRoleId = ($existingAppRoles | Where-Object {$_.Value -eq $appRole }).Id

    if (!$appRoleId) {
        throw "App role ${appRole} not found in app registration ${appRegistrationId}"
    }

    # App role assignment
    $appAssignments = Invoke-RestMethod -Method 'Get' -Uri "${graphUrl}/${principalId}/appRoleAssignments" -Headers $headers

    $exists = $appAssignments.value | Where-Object {$_.appRoleId -eq $appRoleId}

    if ($exists) {
        Write-Host "App role assignment already existed for ${appRole} : ${principalId}"
    } else {
        Write-Host "Creating new app role assignment for ${appRole} : ${principalId}"

        $body = @{
            principalId = $principalId
            resourceId = $appRegistrationId
            appRoleId = $appRoleId
        } | ConvertTo-Json

        Invoke-RestMethod -Method "Post" -ContentType "application/json" -Uri "${graphUrl}/${principalId}/appRoleAssignments" -Headers $headers -Body $body
    }
}

$tenantId = $env:tenantId
$apiPrincipalId = $env:principalId
$appRegistrationId = $env:appRegistrationId
$roles = $env:roles

# Graph setup
$graphToken = $(Get-AzAccessToken -Tenant $tenantId -ResourceUrl "https://graph.microsoft.com").Token
$graphUrl = "https://graph.microsoft.com/v1.0/servicePrincipals"
$headers = @{Authorization = "Bearer $graphToken"}

# App registration / getting custom role ids
$appRegistration = Invoke-RestMethod -Method "Get" -Uri "${graphUrl}/${appRegistrationId}" -Headers $headers
$appRoles = $appRegistration.appRoles

$rolesArray = $roles.split(",") | ForEach-Object { 
    Add-AppRoleAssignment -appRole $_ -existingAppRoles $appRoles -graphUrl $graphUrl -headers $headers -principalId $apiPrincipalId -appRegistrationId $appRegistrationId
}

