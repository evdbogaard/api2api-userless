function GetOrCreate-AppRegistration {
    param(
        [string]$name,
        [string]$url,
        [Object]$headers
    )

    $apps = $(Invoke-RestMethod -Method "Get" -Uri $url -Headers $headers).value
    $app = $apps | Where-Object {$_.displayName -eq $name}

    if (!$app) {
        $body = @{
            displayName = $name
        } | ConvertTo-Json

        $app = Invoke-RestMethod -Method "Post" -ContentType "application/json" -Uri $graphUrl -Headers $headers -Body $body
    }

    return $app
}

function Update-AppRoles {
    param(
        [Object]$appRoles,
        [string]$roles,
        [bool]$isDevelopment
    )

    $memberTypes = @("Application")
    if ($isDevelopment) {
        $memberTypes += "User"
    }

    $roles.split(",") | ForEach-Object { 
        $role = $_
        $exists = $appRoles | Where-Object {$_.value -eq $role}

        if (!$exists) {
            $appRoles += @{
                value = $role
                id = (new-guid).Guid
                displayName = $role
                description = $role
                allowedMemberTypes =$memberTypes
            }
        }
    }
    return $appRoles
}

function Update-Scopes {
    param(
        [Object]$scopes,
        [string]$roles
    )

    $combinedScopes = @()
    $roles.split(",") | ForEach-Object { 
        $role = $_ -replace "-"
        $exists = $scopes | Where-Object {$_.value -eq $role}

        if (!$exists) {
            $scopes += @{
                id = (new-guid).Guid
                adminConsentDisplayName = $role
                adminConsentDescription = $role
                userConsentDisplayName = $role
                userConsentDescription = $role
                value = $role
                type = "User"
            }
        }
    }

    return $scopes
}

$tenantId = $env:tenantId
$roles = $env:roles
$isDevelopment = $env:isDevelopment -eq "true"

# Graph setup
$graphToken = $(Get-AzAccessToken -Tenant $tenantId -ResourceUrl "https://graph.microsoft.com").Token
$graphUrl = "https://graph.microsoft.com/v1.0/applications"
$headers = @{Authorization = "Bearer $graphToken"}

$app = GetOrCreate-AppRegistration -name "api2api-registration" -url $graphUrl -headers $headers

$appRoles = Update-AppRoles -appRoles $app.appRoles -roles $roles -isDevelopment $isDevelopment
$scopes = Update-Scopes -scopes $app.api.oauth2PermissionScopes -roles $roles

$body = @{
    appRoles = $appRoles
    api = @{
        oauth2PermissionScopes = $scopes
        preAuthorizedApplications = $app.api.preAuthorizedApplications
    }
} | ConvertTo-Json -Depth 10

$appId = $app.id
Invoke-RestMethod -Method "Patch" -ContentType "application/json" -Uri "${graphUrl}/${appid}" -Headers $headers -Body $body

# Add preAuthorizedApplication (AZ CLI)
if ($isDevelopment) {
    $scopeIds = $scopes | Select-Object -ExpandProperty id
    $preAuthorizedApplications = @()
    $preAuthorizedApplications += @{
        appId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
        delegatedPermissionIds = @(
            $scopeIds
        )
    }
    
    $body = @{
        appRoles = $appRoles
        api = @{
            oauth2PermissionScopes = $scopes
            preAuthorizedApplications = $preAuthorizedApplications
        }
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Method "Patch" -ContentType "application/json" -Uri "${graphUrl}/${appid}" -Headers $headers -Body $body
}

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['applicationId'] = $appId