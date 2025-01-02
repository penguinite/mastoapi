{.define:ssl.}
import std/[httpclient, json], private/common, results
export Instance, APIError, toHumanError, results

type
  OAuthInfo* = object
    authorization_endpoint*: string ## URL where OAuth authorization requests should be sent
    token_endpoint*: string ## URL where OAuth token requests should be sent
    app_registration_endpoint*: string ## URL where app registration requests should be sent.
    revocation_endpoint*: string ## URL where OAuth revocation requests should be sent.
    supported_scopes*: seq[string] ## A list of scopes that are supported by this server


proc getOAuthInfo*(url: string, client: HttpClient | AsyncHttpClient = newHttpClient()): Result[OAuthInfo, APIError] =
  ## Queries the OAuth authorization API and returns an object with all the valuable info.
  ## 
  ## If the server doesn't support this API then an InvalidCall error is returned.
  let response = client.request(
    url & ".well-known/oauth-authorization-server",
    httpMethod = HttpGet
  )

  if getCode(response) != 200:
    result.err(AE.InvalidCall)
    return

  try:
    let json = parseJson(getBody(response))

    # We have to unpack the list ourselves cause
    # std/json doesn't provide a convenient getStrElems()
    var scopes: seq[string]
    for elem in json["scopes_supported"].getElems():
      scopes.add(elem.getStr())

    result.ok OAuthInfo(
      authorization_endpoint: json["authorization_endpoint"].getStr(),
      token_endpoint: json["token_endpoint"].getStr(),
      app_registration_endpoint: json["app_registration_endpoint"].getStr(),
      revocation_endpoint: json["revocation_endpoint"].getStr(),
      supported_scopes: scopes
    )
  except:
    result.err(AE.ResponseParseFail) # TODO: Maybe this type of error handling is bad?


proc getOAuthInfo*(ins: Instance, client: HttpClient | AsyncHttpClient = newHttpClient()): Result[OAuthInfo, APIError] =
  # This interface was added in Mastodon 4.3.0
  # So we just throw an error if the instance's version is less than 4.3.0
  if ins.version >= (4,3,0):
    return getOAuthInfo(ins.url, client)
  result.err(AE.InvalidCall)