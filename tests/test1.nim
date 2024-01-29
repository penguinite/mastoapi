import mastoapi/apps
import std/options

let app = createApp("mastodon.social", "MastoAPI Test").get()
echo app.exportApp()