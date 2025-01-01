{.define:ssl.}
import std/[httpclient, strutils, json, times], private/common, results
export APIError, toHumanError, results

type
  Application* = object of RootObj ## Defined in https://docs.joinmastodon.org/entities/Application/
    name*: string
    website*: string
    vapid_key*: string ## May be removed in favor of a standalone proc or object.
    scopes*: seq[string]
    redirect_uris*: seq[string]
  
  CredentialApplication* = object of Application ## Defined in https://docs.joinmastodon.org/entities/Application/#CredentialApplication
    client_id*: string
    client_secret*: string
    secret_expiration*: DateTime

proc createApp*(
  url, name, website: string, 
  scopes: seq[string],
  redirect_uris: seq[string] = @[],
  client = newHttpClient()
): Result[APIError, CredentialApplication] =
  let response = client.request(
    url & "api/v1/apps",
  )