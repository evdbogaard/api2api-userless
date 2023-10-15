using Azure.Core;

using Microsoft.AspNetCore.Mvc;

namespace Api2Api.Api1.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TokenController : ControllerBase
{
    private readonly TokenCredential _tokenCredential;
    private readonly TokenRequestContext _requestContext;

    public TokenController(IConfiguration configuration, TokenCredential tokenCredential)
    {
        _tokenCredential = tokenCredential;
        _requestContext = new([$"api://{configuration.GetValue("AppRegistrationId", string.Empty)}/.default"]);
    }

    [HttpGet]
    public async Task<string> GetAzureToken()
    {
        var token = await _tokenCredential.GetTokenAsync(_requestContext, HttpContext.RequestAborted);
        return token.Token;
    }
}
