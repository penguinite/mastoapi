{.deprecated: "DO NOT USE, THIS IS EXTREMELY BROKEN.".}

## Wraps over various different HTTP client implementations.
## This wrapper tries to mimic std/httpclient as reasonably as possible.

const msapiHttpClient*{.strdefine.} = "puppy"
const msapiUserAgent*{.strdefine.} = "MastoAPI for Nim"
const msapiTimeout*{.intdefine.} = 60
const msapiSchemeUpgrade*{.booldefine.} = true

when msapihttpClient == "httpclient":
  # No need to do anything here ¯\_(ツ)_/¯
  import std/[httpclient, streams, strutils]
  export httpclient

  proc set*(data: var MultipartData, stuff: openArray[(string,string)]) =
    ## This procedule is used to set multiple values to MultipartData all at once.
    ## It helps keep the codebase clean, but its a minor effect.
    for key,val in items(stuff):
      data[key] = val

  proc set*(headers: var HttpHeaders, stuff: openArray[(string,string)]) =
    headers = newHttpHeaders(stuff, false)

  # Returns the body
  proc getBody*(obj: Response): string = return readAll(obj[].bodyStream)

  # Returns the HTTP Status Code (as int)
  func getCode*(obj: Response): int = return parseInt(split(obj[].status, " ")[0])

when msapihttpClient == "puppy":
  import puppy, std/strutils
  export puppy

  type
    HttpMethod* = enum
      HttpGet, HttpPost
    
    # "Shell" object
    HttpClient* = object
  
  proc newHttpClient*(str: string): HttpClient = return
  
  proc newHttpHeaders*(): HttpHeaders =
    # Add user-agent
    result["user-agent"] = msapiUserAgent
    # Add gzip encoding thing
    result["accept-encoding"] = "gzip"
    return result

  proc set*(data: var HttpHeaders, stuff: openArray[(string,string)]) =
    for key,val in items(stuff):
      data[key] = val
    
  proc newMultipartData*(): seq[MultipartEntry] = return result

  proc set*(data: var seq[MultipartEntry], stuff: openArray[(string,string)]) =
    for key,val in items(stuff):
      data.add(MultipartEntry(name: key, payload: val))

  proc parseBody(body: string = "", multipart: seq[MultipartEntry] = @[]): string = 
    if body == "":
      return encodeMultipart(multipart)[1]
    if multipart == @[]:
      return body
    # If we're here then we can just return nothing as a safe measure.
    return ""

  proc handleScheme(url: string): string =
    if not url.startsWith("https://") or not url.startsWith("http://"):
      when msapiSchemeUpgrade == true:
        result = "https://" & url
      else:
        result = "http://" & url
    return result
      
  proc request*(client: HttpClient, url: string, kind: HttpMethod, body: string = "", headers: HttpHeaders = @[], multipart: seq[MultipartEntry] = @[]): Response =
    case kind:
    of HttpGet: return get(handleScheme(url), headers, msapiTimeout)
    of HttpPost: return post(handleScheme(url), headers, parseBody(body, multipart), msapiTimeout)


  ## I am surprisingly delighted by Puppy's sane and sensible Response object.
  ## No need for hacky workarounds like in std/httpclient, just simple easily readable code.
  ## Sadly std/httpclient can't change now!
  # Returns the body
  proc getBody*(obj: Response): string = return obj[].body

  # Returns the HTTP Status Code (as int)
  func getCode*(obj: Response): int = return obj[].code


when msapihttpClient == "curly":
  # TODO: Pls finish this
  {.warning: "Curly support is unfinished".}
  type
    HttpMethod = enum
      HttpGet, HttpPost