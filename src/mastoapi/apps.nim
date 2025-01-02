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
  url, name: string,
  website = "", 
  scopes = @["read"],
  redirect_uris = @["urn:ietf:wg:oauth:2.0:oob"],
  client: HttpClient | AsyncHttpClient = newHttpClient()
): Result[APIError, CredentialApplication] =
  

  var headers: HttpHeaders
  headers.set(
    {"Content-Type": "application/json"}
  )

  let response = client.request(
    url & "api/v1/apps",
    httpMethod = HttpPost,
    header
    body = $(%* {"client_name": name,"redirect_uris": redirect_uris,"scopes": scopes,"website": website})
  )



