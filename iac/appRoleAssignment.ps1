$tenantId = $env:tenantId

$apiPrincipalId = $env:principalId

Msgraph-login --tenant $tenantId
$exists = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $apiPrincipalId -ErrorAction SilentlyContinue

if (!$exists) {
    $appRegistration = Get-MgServicePrincipal -Filter "DisplayName eq 'api2api-test'"
    $resourceId = $appRegistration.Id
    $appRoleId = ($appRegistration.AppRoles | Where-Object {$_.Value -eq 'app_role_access_mi' }).Id

    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $apiPrincipalId -PrincipalId $apiPrincipalId -ResourceId $resourceId -AppRoleId $appRoleId
}



