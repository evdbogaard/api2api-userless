using Microsoft.AspNetCore.Mvc;

namespace Api2Api.Api1.Controllers;

[Route("api/[controller]")]
[ApiController]
public class DemoController : ControllerBase
{
    private readonly HttpClient _api2Client;

    public DemoController(IHttpClientFactory httpClientFactory)
    {
        _api2Client = httpClientFactory.CreateClient("api2");
    }

    [HttpGet]
    public async Task DemoCall()
    {
        await Task.CompletedTask;
    }
}