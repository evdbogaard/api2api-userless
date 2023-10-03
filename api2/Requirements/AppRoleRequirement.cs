﻿using System.IdentityModel.Tokens.Jwt;

using Microsoft.AspNetCore.Authorization;

namespace api2api.api2;

public class AppRoleRequirement : AuthorizationHandler<AppRoleRequirement>, IAuthorizationRequirement
{
    public readonly string Id;

    public AppRoleRequirement(string id)
    {
        ArgumentNullException.ThrowIfNullOrWhiteSpace(id);
        Id = id;
    }

    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, AppRoleRequirement requirement)
    {
        if (context.HasFailed)
            return Task.CompletedTask;

        var roles = context.User.Claims.Where(c => c.Type == "roles").ToList();
        var aud = context.User.Claims.Where(c => c.Type == JwtRegisteredClaimNames.Aud).FirstOrDefault();
        var roleClaim = context.User.Claims.Where(c => c.Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/role").FirstOrDefault();
        if (aud?.Value == $"api://{requirement.Id}" && roleClaim != null && roleClaim.Value == "app_role_access_mi")
            context.Succeed(requirement);
        else
            context.Fail();

        return Task.CompletedTask;
    }
}