
type
  Instance* = object
    url*: string ## The URL of the instance being used
    version*: (int, int, int) ## The version of the instance being used

proc newInstance*(url: string): Instance =
  ## Returns an Instance object, ready for use.
  ## 
  ## Note: You don't have to use Instance if you don't want to, you could simply just supply a URL for most API calls.
  ## But this is useful for when you wanna use API routes that might not be available everywhere.
  
  # Add trailing slash if it doesn't exist
  result.url = url
  if url[high(url)] != '/':
    result.url.add('/')
  
  

## Comparators
#proc `>=`*(a,b: (int, int, int)): bool =
#  return a[0] >= b[0] and a[1] >= b[1] and a[2] >= b[2]
#proc `>`*(a,b: (int, int, int)): bool =
#  return a[0] > b[0] and a[1] > b[1] and a[2] > b[2]
#proc `<=`*(a,b: (int, int, int)): bool =
#  return a[0] <= b[0] and a[1] <= b[1] and a[2] <= b[2]
#proc `<`*(a,b: (int, int, int)): bool =
#  return a[0] < b[0] and a[1] < b[1] and a[2] < b[2]

# API Error core.

type APIError* {.pure.} = enum # An enum uniquely identifying every error, intended for non-human consumption.
  ConnectionFailed, InvalidCall

func toHumanError*(e: APIError): string =
  ## Takes a machine-readable APIError enum and returns a human-readable string intended for diagnostics or logging.
  case e:
  of ConnectioNFailed: return "Couldn't connect to the server."
  of InvalidCall: return "MastoAPI server doesn't support this API route/call"