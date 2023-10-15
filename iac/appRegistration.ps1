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

        $body = @{
            appId = $app.appId
            tags = @("WindowsAzureActiveDirectoryIntegratedApp", "HideApp")
        } | ConvertTo-Json

        $servicePrincipal = Invoke-RestMethod -Method "Post" -ContentType "application/json" -Uri "https://graph.microsoft.com/v1.0/servicePrincipals" -Headers $headers -Body $body
    } else {
        $urlServicePrincipal = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '${name}'"
        $servicePrincipal = (Invoke-RestMethod -Method "Get" -Uri $urlServicePrincipal -Headers $headers).value[0]
    }

    return @($app, $servicePrincipal)
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

    $scopeName = "access_api"
    $exists = $scopes | Where-Object {$_.value -eq $scopeName}

    if (!$exists) {
        $scopes +=
            @{
                id = (new-guid).Guid
                adminConsentDisplayName = $scopeName
                adminConsentDescription = $scopeName
                userConsentDisplayName = $scopeName
                userConsentDescription = $scopeName
                value = $scopeName
                type = "User"
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

$appBuilder = GetOrCreate-AppRegistration -name "api2api-registration" -url $graphUrl -headers $headers
$app = $appBuilder[0]
$servicePrincipal = $appBuilder[1]

$appRoles = Update-AppRoles -appRoles $app.appRoles -roles $roles -isDevelopment $isDevelopment
$scopes = @(Update-Scopes -scopes $app.api.oauth2PermissionScopes -roles $roles)

$applicationId = $app.appId
$body = ConvertTo-Json -Depth 10 @{
    signInAudience = "AzureADMyOrg"
    identifierUris = @("api://${applicationId}")
    appRoles = $appRoles
    api = @{
        oauth2PermissionScopes = $scopes
        preAuthorizedApplications = $app.api.preAuthorizedApplications
    }
}

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
    
    $body = ConvertTo-Json -Depth 10 @{
        signInAudience = "AzureADMyOrg"
        identifierUris = @("api://${applicationId}")
        appRoles = $appRoles
        api = @{
            oauth2PermissionScopes = $scopes
            preAuthorizedApplications = $preAuthorizedApplications
        }
    }

    Invoke-RestMethod -Method "Patch" -ContentType "application/json" -Uri "${graphUrl}/${appid}" -Headers $headers -Body $body
}

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['applicationId'] = $applicationId
$DeploymentScriptOutputs['servicePrincipalObjectId'] = $servicePrincipal.id