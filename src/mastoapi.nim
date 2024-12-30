import std/json
import mastoapi/[apps, oauth, emojis, types]
export apps, oauth, emojis, types

proc importJson*[T](json: JsonNode, obj: T): T =
  ## This allows you to take a JsonNode and convert it to any other object. This is useful for saving data such as app tokens.
  ## *Note*: The JSON input *has* to exactly match the object's layout. In other words: use exportString() to generate the string you want to import.
  return json.to(obj)  

proc importString*[T](json: string, obj: T): T =
  ## This allows you to take a JSON string and convert it to any object. This is useful for saving data such as app tokens.
  ## *Note*: The JSON input *has* to exactly match the object's layout. In other words: use exportString() to generate the string you want to import.
  return parseJson(json).to(obj)

proc exportString*[T](app: T): string =
  ## This procedure takes any object, and turns it into a string that can be imported later via importString()
  ## 
  ## Fx. you could import app tokens, or some other secret and save that in a file to import later.
  ## So you do not keep on making new createApp() requests.
  return $(%* app)

proc exportJson*[T](app: T): JsonNode =
  ## This procedure takes any object, and turns it into a JsonNode that can be imported later via importJson()
  ## 
  ## Fx. you could import app tokens, or some other secret and save that in a file to import later.
  ## So you do not keep on making new createApp() requests.
  return %* app