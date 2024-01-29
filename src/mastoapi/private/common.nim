import std/[json, times, strutils, options]
export json, times, options, strutils

# Various helper functions for dealing with the Response object

# Templates and stuff for dealing with Json.
proc isValid*(json: JsonNode, key: string): bool =
  if not json.contains(key): return false
  
  case json.kind:
  of JString:
    # If string is mostly empty then ignore it
    return not isEmptyOrWhitespace(json[key].getStr())
  of JInt:
    # We do not want negative numbers most of the time.
    return json[key].getInt() > -1
  else:
    return true # Let's hope it does not crash!

template safeString*[T](json: JsonNode, obj: var T, key: string): untyped {.dirty.} =
  if json.contains(key) and json[key].kind == JString and not isEmptyOrWhitespace(json[key].getStr()):
    obj = json[key].getStr()

template plainString*[T](json: JsonNode, obj: var T, key: string): untyped {.dirty.} =
  if json.contains(key) and json[key].kind == JString:
    obj = json[key].getStr()

template SpaceSepSequence*[T](json: JsonNode, obj: var T, key: string): untyped {.dirty.} =
  if json.contains(key) and json[key].kind == JString and not isEmptyOrWhitespace(json[key].getStr()):
    obj = split(json[key].getStr(),"")

template boolean*[T](json: JsonNode, obj: var T, key: string): untyped {.dirty.} =
  if json.contains(key) and json[key].kind == JBool:
    obj = json[key].getBool()

template unixTimestamp*[T](json: JsonNode, obj: var T, key: string): untyped {.dirty.} =
  if json.contains(key) and json[key].kind == JInt and json.getInt() > -1:
    obj = utc(fromUnix(json.getInt()))