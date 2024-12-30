# Package

version       = "0.1.0"
author        = "penguinite"
description   = "Mastodon API library for Nim"
license       = "BSD-3-Clause"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
requires "results ^= 0.5.1"

## We have to install all three, since nimble doesn't let me
## check for the msapiHttpClient constant here. (It doesn't work! >:()
#requires "puppy"
#requires "curly"