

## Wraps over various different HTTP client implementations.
## This wrapper tries to mimic std/httpclient as reasonably as possible.

const msapiHttpClient*{.strdefine.} = "puppy"
const msapiUserAgent*{.strdefine.} = "MastoAPI for Nim"

when msapihttpClient == "httpclient":
  # No need to do anything here ¯\_(ツ)_/¯
  import std/[httpclient, streams, strutils]
  export httpclient

  proc set*(data: var MultipartData, stuff: openArray[(string,string)]) =
    ## This procedule is used to set multiple values to MultipartData all at once.
    ## It helps keep the codebase clean, but its a minor effect.
    for key,val in items(stuff):
      data[key] = val

  # Returns the body
  proc getBody*(obj: Response): string = return readAll(obj[].bodyStream)

  # Returns the HTTP Status Code (as int)
  func getCode*(obj: Response): int = return parseInt(split(obj[].status, " ")[0])

when msapihttpClient == "puppy":
  import puppy
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
    
  proc newMultipartData*(): MultipartEntry = return result

  proc set*(data: var , stuff: openArray[(string,string)]) =


  proc request(client: HttpClient, uri: string, kind: HttpMethod, body: string, headers: HttpHeaders = nil, multipart: )


when msapihttpClient == "curly":
  type
    HttpMethod = enum
      HttpGet = 
