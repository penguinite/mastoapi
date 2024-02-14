import private/[common, http]
import types
export types

const prefix = "/api/v1/apps"

proc createAppRaw*(instance: string, name: string, uris: string = "urn:ietf:wg:oauth:2.0:oob", scopes:string = "", website: string = ""): Option[JsonNode] =
  let url = instance & prefix
  
  # Fill out form data
  var data = newMultipartData()
  data.set({
    "client_name": name,
    "redirect_uris": uris,
    "scopes": scopes,
    "website": website
  })

  var response = newHttpClient(msapiUserAgent).request(url, HttpPost, "", newHttpHeaders(), data)
  
  if getCode(response) != 200:
    return none(JsonNode)

  return some(getBody(response).parseJson())

proc createApp*(instance: string, name: string, uris: string = "urn:ietf:wg:oauth:2.0:oob", scopes:string = "", website: string = ""): Option[Application] =
  let jayson = createAppRaw(instance, name, uris, scopes, website)

  # Return nothing if the json is empty.
  if isNone(jayson): return none(Application)
  
  let json = jayson.get()

  var obj = Application()

  obj.name = name
  obj.redirect_uri = uris
  obj.website = website
  obj.scopes = scopes

  # If these two are missing, then don't bother.
  if not json.isValid("client_id"): return none(Application)
  if not json.isValid("client_secret"): return none(Application)

  json.safeString(obj.client_id, "client_id")
  json.safeString(obj.client_secret, "client_secret")
  json.safeString(obj.vapid_key, "vapid_key")

  return some(obj)

proc verifyCredentialsRaw*(instance, token: string): Option[JsonNode] =
  ## Returns the raw JSON provided by https://docs.joinmastodon.org/methods/apps/#verify_credentials
  
  let url = instance & prefix & "/verify_credentials"
  var headers = newHttpHeaders()
  headers.set({"Authorization": "Bearer " & token})

  var response = newHttpClient(msapiUserAgent).request(url, HttpPost, "", headers, newMultipartData())

  let code = getCode(response)
  if code != 200 or code != 421:
    return none(JsonNode)

  return some(getBody(response).parseJson())

proc verifyCredentials*(instance, token: string, app_name, vapid_key: string): bool = 
  if instance.isEmptyOrWhitespace() or
     token.isEmptyOrWhitespace() or
     app_name.isEmptyOrWhitespace() or
     vapid_key.isEmptyOrWhitespace:
      return false
  
  let response = verifyCredentialsRaw(instance, token)
  if isNone(response): return false

  try:
    if app_name != "" and response.get()["name"].getStr() != app_name: return false
    if vapid_key != "" and response.get()["name"].getStr() != vapid_key: return false
  except:
    # Just in case the server delivers some weird JSON response
    return false

  return true

proc verifyCredentials*(token: Token, app: Application): bool =
  ## A wrapper over verifyCredentialsWeak() for convenience. The token and application objects must be filled out with real and valid data.
  return verifyCredentials(token.instance, token.access_token, app.name, app.vapid_key)
  
proc verifyCredentials*(token: Option[Token], app: Option[Application]): bool =
  if isNone(token) or isNone(app): return false
  return verifyCredentials(token.get(), app.get())


proc verifyCredentialsWeak*(instance, token: string, name: string = ""): bool  =
  ## Out of the two verifyCredentials proc, this one is the weakest.
  ## It checks for a successful request from the server, and the app's name (but not the app's vapid key).
  ## You should only use this if you are trying to support Mastodon servers older than 2.7.2
  ## For anything newer, use the normal verifyCredentials() proc
  ## If you are unsure, use verifyCredentials()
  ## 
  ## `name` means the app name. If you are unsure, then don't supply it. But be aware that the check will be very weak.
  if instance.isEmptyOrWhitespace() or
     token.isEmptyOrWhitespace() or
     name.isEmptyOrWhitespace():
      return false

  let response = verifyCredentialsRaw(instance, token)
  if isNone(response): return false

  try:
    if name != "" and response.get()["name"].getStr() != name: return false
  except:
    # Just in case the server delivers some weird JSON response
    return false

  return true

proc verifyCredentialsWeak*(token: Token, app: Application): bool =
  ## A wrapper over verifyCredentialsWeak() for convenience. The token and application objects must be filled out with real and valid data.
  return verifyCredentialsWeak(token.instance, token.access_token, app.name)

proc verifyCredentialsWeak*(token: Option[Token], app: Option[Application]): bool =
  if isNone(token) or isNone(app): return false
  return verifyCredentialsWeak(token.get(), app.get())