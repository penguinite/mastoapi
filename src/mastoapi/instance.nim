{.define:ssl.}
import std/[httpclient, strutils, json], private/common, results
export Instance, APIError, toHumanError, results

func parseInstanceVersion*(ver: string): (int, int, int) =
  ## Parses an instance version (string given out by the /api/v1/instance or /api/v2/instance API routes)
  
  # We know the version must have at least 3 dots
  # So we split the string by dots
  # and parseInt() elements 0, 1 and 2 to get our results.
  let s = ver.split('.')
  return (
    parseInt(s[0]),
    parseInt(s[1]),
    parseInt(s[2])
  )

proc newInstance*(url: string): Instance =
  ## Returns an Instance object, ready for use.
  ## 
  ## Note: You don't have to use Instance if you don't want to, you could simply just supply a URL for most API calls.
  ## But this is useful for when you wanna use API routes that might not be available everywhere.
  
  # Add trailing slash if it doesn't exist
  result.url = url
  if url[high(url)] != '/':
    result.url.add('/')
  
  let client = newHttpClient()
  # We try /api/v2/instance first...
  # If it fails, then we try the older API.
  var response = client.request(
    result.url & "api/v2/instance",
    httpMethod = HttpGet
  )

  if getCode(response) == 200:
    let json = parseJson(getBody(response))
    result.version = parseInstanceVersion(json["version"].getStr())
    return result

  # We try old API now :)
  
  response = client.request(
    result.url & "api/v1/instance",
    httpMethod = HttpGet
  )

  if getCode(response) == 200:
    let json = parseJson(getBody(response))
    result.version = parseInstanceVersion(json["version"].getStr())
    return result

  result.version = (0,0,0) # Unknown version.