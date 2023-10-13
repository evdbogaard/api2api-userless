
using System.Net.Http.Headers;

using Azure.Core;

namespace Api2Api.Api1.Handlers;

public class AzureAuthHandler : DelegatingHandler
{
    private readonly TokenCredential _tokenCredential;
    private readonly TokenRequestContext _requestContext;

    public AzureAuthHandler(TokenCredential tokenCredential, string[] scopes)
    {
        _tokenCredential = tokenCredential;
        _requestContext = new TokenRequestContext(scopes);
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var result = await _tokenCredential.GetTokenAsync(_requestContext, cancellationToken);
        Console.WriteLine(result.Token);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", result.Token);

        return await base.SendAsync(request, cancellationToken);
    }
}
