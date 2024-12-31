import std/[httpclient, streams, strutils]

type
  Instance* = object
    url*: string ## The URL of the instance being used
    version*: (int, int, int) ## The version of the instance being used

  APIError* {.pure.} = enum # An enum uniquely identifying every error, intended for non-human consumption.
    ConnectionFailed, InvalidCall, ResponseParseFail

func toHumanError*(e: APIError): string =
  ## Takes a machine-readable APIError enum and returns a human-readable string intended for diagnostics or logging.
  case e:
  of ConnectioNFailed: return "Couldn't connect to the server."
  of InvalidCall: return "MastoAPI server doesn't support this API route/call"
  of ResponseParseFail: return "MastoAPI server response couldn't be parsed properly..."

type AE* = ApiError

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