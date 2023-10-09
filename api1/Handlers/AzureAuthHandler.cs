
using System.Net.Http.Headers;

using Azure.Core;

namespace Api2Api.Api1.Handlers;

public class AzureAuthHandler : DelegatingHandler
{
    private readonly TokenCredential _tokenCredential;

    public AzureAuthHandler(TokenCredential tokenCredential)
    {
        _tokenCredential = tokenCredential;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var tokenRequestContext = new TokenRequestContext(["api://e3b0ed2b-9168-41d1-8a5c-44c31477ae89/.default"]);
        var result = await _tokenCredential.GetTokenAsync(tokenRequestContext, cancellationToken);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", result.Token);

        return await base.SendAsync(request, cancellationToken);
    }
}

public static class HttpBuilderExtensions
{
    public static IHttpClientBuilder WithAzureAuthentication(this IHttpClientBuilder httpClientBuilder) //, IServiceCollection services, TokenCredential tokenCredential, string[] scopes)
    {
        // services.GetR
        return httpClientBuilder.AddHttpMessageHandler<AzureAuthHandler>();
    }
}
