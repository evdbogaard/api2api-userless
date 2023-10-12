$tenantId = $env:tenantId
$servers = $env:servers

# Graph setup
$graphToken = $(Get-AzAccessToken -Tenant $tenantId -ResourceUrl "https://graph.microsoft.com").Token
$graphUrl = "https://graph.microsoft.com/v1.0/applications"
$headers = @{Authorization = "Bearer $graphToken"}

# Create
# $body = @{
#         displayName = "api2api-newtest"
#     } | ConvertTo-Json

# Invoke-RestMethod -Method "Post" -ContentType "application/json" -Uri "${graphUrl}" -Headers $headers -Body $body

$name = "test-api" -replace "-"

$body = @{
    appRoles = @(
        @{
            value = "test-api"
            id = "67a13158-ae23-416c-8382-f46f2c6c863d" # (new-guid).Guid
            displayName = "test-api"
            description = "test-api"
            allowedMemberTypes = @("User", "Application")
        }
    )
    api = @{
        oauth2PermissionScopes = @(
            @{
                id= (new-guid).Guid
                adminConsentDisplayName= $name
                adminConsentDescription= $name
                userConsentDisplayName= $name
                userConsentDescription= $name
                value= $name
                type= "User"
                isEnabled= $true
            }
            # @{
            #     # adminConsentDescription = "test-api"
            #     # adminConsentDisplayName = "test-api"
            #     id = (new-guid).Guid
            #     type = "User"
            #     # userConsentDescription = "test-api"
            #     # userConsentDisplayName = "test-api"
            #     value = "test-api"
            # }
        )
    }
} | ConvertTo-Json -Depth 10

Write-Host $body

Invoke-RestMethod -Method "Patch" -ContentType "application/json" -Uri "${graphUrl}/b61d3b68-f01a-4e1e-a085-c59557c21450" -Headers $headers -Body $body