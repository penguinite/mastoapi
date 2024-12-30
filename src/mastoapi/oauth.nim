import results, private/common

type
  OAuthInfo* = object
    authorization_endpoint*: string ## URL where OAuth authorization requests should be sent
    token_endpoint*: string ## URL where OAuth token requests should be sent
    app_registration_endpoint*: string ## URL where app registration requests should be sent.
    revocation_endpoint*: string ## URL where OAuth revocation requests should be sent.
    supported_scopes*: seq[string] ## A list of scopes that are supported by this server


proc getOAuthInfo*(url: string, client = newHttpClient()): Result[OAuthInfo, APIError] =
  let json = parseJson(getContent())
  echo "Ok"
  return


proc getOAuthInfo*(ins: Instance): Result[OAuthInfo, APIError] =
  # This interface was added in Mastodon 4.3.0
  # So we just throw an error if the instance's version is less than 4.3.0
  if ins.version >= (4,3,0):
    return getOAuthInfo(ins.url)
  result.err(AE.InvalidCall)


discard getOAuthInfo(Instance(
  url: "a", version: (4,1,0)
))