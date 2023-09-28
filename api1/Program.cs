using System.Net.Http.Headers;

using Azure.Core;
using Azure.Identity;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddControllers();

var credential = new AzureCliCredential();
AccessToken? accessToken = null;
try
{
    accessToken = credential.GetToken(new TokenRequestContext(new[] { "api://e3b0ed2b-9168-41d1-8a5c-44c31477ae89/.default"}));
} 
catch (Exception ex)
{
    Console.WriteLine(ex.Message);
}


var token = accessToken.HasValue ? accessToken.Value.Token : string.Empty;
Console.WriteLine(string.Join(".", token.Split('.').Take(2)));

builder.Services.AddHttpClient("api2", options =>
{
    options.BaseAddress = new Uri("https://localhost:7027/api/");
    options.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.MapControllers();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}