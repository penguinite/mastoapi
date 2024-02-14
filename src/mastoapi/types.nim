from std/times import DateTime

type
  Token* = object ## Defined in https://docs.joinmastodon.org/entities/Token/
    instance*, access_token*, token_type*: string
    scope*: string
    created_at*: DateTime ## This is converted from a Unix Epoch timestamp

type
  Application* = object ## Defined in https://docs.joinmastodon.org/entities/Application/
    name*, website*, vapid_key*, client_id*, client_secret*: string
    scopes*, redirect_uri*: string # These are stored just in case the client needs to check a permission or something.

type
  Emoji* = object ## Defined in https://docs.joinmastodon.org/entities/CustomEmoji/
    shortcode*, url*, static_url*, category*: string
    visible_in_picker*: bool
