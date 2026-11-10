#!/bin/bash -e

SELF_URL='https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD'
PROFILE_DIR="$(find "${HOME}/Library/Application Support/Firefox/Profiles" -maxdepth 1 -name '*.default-release' | head -n 1)"
DISTRIBUTION_DIR='/Applications/Firefox.app/Contents/Resources/distribution'

# Definitely don't want Firefox running while we're messing with it
killall firefox && sleep 2

# Replace all user preferences with our stub prefs, which will rebuild on next restart
curl -fL "${SELF_URL}/firefox/prefs.js" -o "${PROFILE_DIR}/prefs.js"

# [106.0] Delete all the factory bookmarks, but don't wreck the folder structure
sqlite3 "${PROFILE_DIR}/places.sqlite" 'DELETE FROM `moz_bookmarks` WHERE `parent` > 1;'

# [159.0] Install a few add-ons that I want everywhere
# HACK Also really hammer on `browser.ai.control.sidebarChatbot` which doesn't work via prefs
mkdir -p "${DISTRIBUTION_DIR}"
curl -fL "${SELF_URL}/firefox/policies.json" -o "${DISTRIBUTION_DIR}/policies.json"

# Launch Firefox, then maximize its window(s)
echo 'Starting Firefox now, wait a few seconds...'
open -F /Applications/Firefox.app && sleep 5
osascript -e 'tell application "Firefox" to tell every window to set zoomed to true'

# This isn't cleanly scriptable and I wouldn't want to try it anyway
echo
echo '===================='
echo
echo 'Firefox is now set up. Perform the following tweaks manually:'
echo '  - Privacy Badger'
echo '    - Interact with the menu and dismiss the welcome banner'
echo '  - uBlock Origin'
echo '    - Click "More" until the window widens'
echo '    - Activate all "Cookie notices" filter lists'
echo '    - Activate all "Annoyances" filter lists'
echo
echo 'All other add-ons should be placed alphabetically in the "Extensions" menu.'
