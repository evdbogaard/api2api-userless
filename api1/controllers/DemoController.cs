using System.Security.Authentication;

using Microsoft.AspNetCore.Mvc;

namespace Api2Api.Api1.Controllers;

[Route("api/[controller]")]
[ApiController]
public class DemoController : ControllerBase
{
    private readonly HttpClient _api2Jwt;
    private readonly HttpClient _api2Azure;

    public DemoController(IHttpClientFactory httpClientFactory)
    {
        _api2Jwt = httpClientFactory.CreateClient("jwt");
        _api2Azure = httpClientFactory.CreateClient("azure");
    }

    [HttpGet("JwtDefault")]
    public async Task<string> JwtDefault()
    {
        var result = await _api2Jwt.GetAsync("Demo");
        if (!result.IsSuccessStatusCode)
            throw new AuthenticationException();
        return await result.Content.ReadAsStringAsync();
    }

    [HttpGet("AzureDefault")]
    public async Task<string> AzureDefault()
    {
        var result = await _api2Azure.GetAsync("Demo");
        if (!result.IsSuccessStatusCode)
            throw new AuthenticationException();
        return await result.Content.ReadAsStringAsync();
    }

    [HttpGet("JwtCombined")]
    public async Task<string> JwtCombined()
    {
        var result = await _api2Jwt.GetAsync("Demo/Combined");
        if (!result.IsSuccessStatusCode)
            throw new AuthenticationException();
        return await result.Content.ReadAsStringAsync();
    }

    [HttpGet("AzureCombined")]
    public async Task<string> AzureCombined()
    {
        var result = await _api2Azure.GetAsync("Demo/Combined");
        if (!result.IsSuccessStatusCode)
            throw new AuthenticationException();
        return await result.Content.ReadAsStringAsync();
    }

    [HttpGet("JwtAzureOnly")]
    public async Task<string> JwtAzureOnly()
    {
        var result = await _api2Jwt.GetAsync("Demo/AzureAdOnly");
        if (!result.IsSuccessStatusCode)
            throw new AuthenticationException();
        return await result.Content.ReadAsStringAsync();
    }

    [HttpGet("AzureAzureOnly")]
    public async Task<string> AzureAzureOnly()
    {
        var result = await _api2Azure.GetAsync("Demo/AzureAdOnly");
        if (!result.IsSuccessStatusCode)
            throw new AuthenticationException();
        return await result.Content.ReadAsStringAsync();
    }
}