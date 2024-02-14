import private/common
import types
export types


proc parseEmojis*(json: JsonNode): seq[Emoji] =
  result = @[]
  if json.contains("emojis"):
    for emoji in json["emojis"].getElems():
      var newemoji: Emoji;

      json.safeString(newemoji.shortcode, "shortcode")
      json.safeString(newemoji.url, "url")
      json.safeString(newemoji.static_url, "static_url")
      json.boolean(newemoji.visible_in_picker, "visible_in_picker")
      result.add(newemoji)
  
  return result