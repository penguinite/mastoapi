import private/[common, http]
import types
export types

const prefix = "/oauth"

proc createTokenRaw*(instance, client_id, client_secret, redirect_uri, scopes: string , user_code: string = ""): Option[JsonNode] = 
  let url = instance & prefix & "/token"

  var data = newMultipartData()
  
  # Depending on whether user_code is set.
  # Make grant_type authorization_code or client_credentials
  if user_code != "":
    data.set({
      "grant_type": "authorization_code",
      "code": user_code
    })
  else:
    data.set({"grant_type": "client_credentials"})

  data.set({
    "client_id": client_id,
    "client_secret": client_secret,
    "redirect_uri": redirect_uri,
    "scopes": scopes
  })

  var response = newHttpClient(msapiUserAgent).request(url, HttpPost, "", newHttpHeaders(), data)

  if getCode(response) != 200: return none(JsonNode)

  return some(getBody(response).parseJson())


proc createTokenRaw*(instance: string, app: Application, user_code: string = ""): Option[JsonNode] = 
  return createTokenRaw(instance, app.client_id, app.client_secret, app.redirect_uri, app.scopes, user_code)

proc createToken*(instance, client_id, client_secret, redirect_uri, scopes: string , user_code: string = ""): Option[Token] = 
  ## https://docs.joinmastodon.org/methods/oauth/#token
  ## the `user_code` parameter should only be filled if you want to use a user authorization code.
  ## Do not fill it if you want app-only access, ie `client_credentials` grant type.
  ## Remember to make sure the api.app object is filled with createApp() or importApp()
  ## Otherwise the API will throw out an error.
  let jayson = createTokenRaw(instance, client_id, client_secret, redirect_uri, scopes, user_code)

  if isNone(jayson): return none(Token)

  let json = jayson.get()

  var obj: Token;

  # Check the most important part for validity.
  if not json.isValid("access_token"): return none(Token)

  json.safeString(obj.access_token, "access_token")
  json.safeString(obj.token_type, "token_type")  
  obj.scope = scopes

  json.unixTimestamp(obj.created_at, "created_at")
  obj.instance = instance

  return some(obj)

proc createToken*(instance: string, app: Application, user_code: string = ""): Option[Token] = 
  return createToken(instance, app.client_id, app.client_secret, app.redirect_uri, app.scopes, user_code)