#!/bin/bash -e

SELF_URL='https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD'
PROFILE_DIR="$(find "${HOME}/Library/Application Support/Firefox/Profiles" -maxdepth 1 -name '*.default-release' | head -n 1)"

# Definitely don't want Firefox running while we're messing with it
killall firefox && sleep 2

# Replace all user preferences with our stub prefs, which will rebuild on next restart
curl -fL "${SELF_URL}/firefox/prefs.js" -o "${PROFILE_DIR}/prefs.js"

# [106.0] Delete all the factory bookmarks, but don't wreck the folder structure
sqlite3 "${PROFILE_DIR}/places.sqlite" 'DELETE FROM `moz_bookmarks` WHERE `parent` > 1;'

# Launch Firefox, then maximize its window(s)
echo 'Starting Firefox now, wait a few seconds...'
open -F /Applications/Firefox.app && sleep 5
osascript -e 'tell application "Firefox" to tell every window to set zoomed to true'

# This isn't cleanly scriptable and I wouldn't want to try it anyway
echo
echo '===================='
echo
echo 'Firefox is now set up. Install the following add-ons manually:'
echo '  - https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/ [allow in Private Windows = on]'
echo '  - https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/ [allow in Private Windows = on]'
echo '  - https://addons.mozilla.org/en-US/firefox/addon/i-dont-care-about-cookies/ [allow in Private Windows = on]'
echo
echo 'Privacy Badger and uBlock Origin go in the toolbar.'
echo 'All other add-ons should be placed alphabetically in the "More tools..." menu.'
