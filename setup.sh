#!/bin/bash -e

# ====================
# Parse environment
# ====================

OS_MAJOR_VERSION="$(sw_vers -productVersion | sed -nr 's/^([0-9]+).*/\1/p')"
SET_HOSTNAME="${SET_HOSTNAME:-$(scutil --get LocalHostName)}"
INCLUDE_SOFTWARE_UPDATE="${INCLUDE_SOFTWARE_UPDATE:-true}"
INCLUDE_WORKTOOLS="${INCLUDE_WORKTOOLS:-false}"
CAPITALIZE_DISK="${CAPITALIZE_DISK:-unset}"

echo    "OS_MAJOR_VERSION:        ${OS_MAJOR_VERSION}"
echo    "SET_HOSTNAME:            ${SET_HOSTNAME}"
echo    "INCLUDE_SOFTWARE_UPDATE: ${INCLUDE_SOFTWARE_UPDATE}"
echo    "INCLUDE_WORKTOOLS:       ${INCLUDE_WORKTOOLS}"
echo -n "CAPITALIZE_DISK:         ${CAPITALIZE_DISK}"

if [ "$CAPITALIZE_DISK" = 'unset' ]; then
    # If the existing volume name starts with a capital, default CAPITALIZE_DISK
    # to true. Otherwise it defaults to false.
    vol="$(diskutil info / | sed -nE 's/^.*Volume Name: *(.+)$/\1/p')"
    volupper="$(tr '[:lower:]' '[:upper:]' <<< "${vol:0:1}")${vol:1}"
    [ "$vol" = "$volupper" ] && CAPITALIZE_DISK='true' || CAPITALIZE_DISK='false'
    echo " -> ${CAPITALIZE_DISK}"
else
    echo ''
fi

DISKNAME="$SET_HOSTNAME"
if [ "$CAPITALIZE_DISK" = 'true' ]; then
    DISKNAME="$(tr '[:lower:]' '[:upper:]' <<< "${DISKNAME:0:1}")${DISKNAME:1}"
fi

echo "Final Disk Name:         ${DISKNAME}"

nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version &>/dev/null && USES_OPENCORE='true' || USES_OPENCORE='false'
echo "Uses OpenCore boot:      ${USES_OPENCORE}"

# Make a base64-encoded blob containing a binary plist.
# $1: Complete XML-readable plist document.
# Returns a string like "<data>AA...A=</data>".
_make_bplist() {
    local plist

    plist="$(mktemp)"
    echo "$1" > "$plist"
    plutil -convert binary1 "$plist"
    echo "<data>$(base64 -i "$plist")</data>"
    rm -f "$plist"
}

# ====================
# Initialization
# ====================

SELF_URL='https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD'

# Ask for the administrator password at the very beginning...
sudo -v

# ... and (unsafely, lazily) refresh it every 50 seconds until killed.
# TODO I really think brew is expiring this each time it runs, or something
while sleep 50; do sudo -v; done &

# If we don't have sudo at this point, no reason to continue
sudo -n true || exit

# ====================
# Early interactive stuff
#
# Everything in here pops up a TCC/PPPC warning, or requires the user (not sudo)
# password to be input. Do all of these early, even though they might logically
# fit better elsewhere in the script, to get all of the interactivity out of the
# way as early as possible.
# ====================

# Try to hit as many paths as possible to satisfy prompts within $HOME.
# Apparently not so necessary starting around 13.0?
echo "Poking around in ${HOME}; please allow access at each prompt..."
find "$HOME" > /dev/null 2>&1

# [12.6] System Preferences > Security & Privacy > FileVault > Turn On FileVault
# [13.7] System Settings > Privacy & Security > FileVault > Turn On...
sudo fdesetup enable -user "$(logname)" | tee "${HOME}/Desktop/FileVault Recovery.txt"

# ====================
# Installations
# ====================

# Install Homebrew (non-interactively)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
if [ -d /opt/homebrew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Install utilities that are required for this script
brew install coreutils dockutil git mysides stow

# Install Consolas font family system-wide
curl -fL "${SELF_URL}/data/fonts/consola{,b,i,z}.ttf" -o '/Library/Fonts/consola#1.ttf'

# Install user profile and background banner images
curl -fL "${SELF_URL}/data/pictures/profile{,-bg}.jpg" -o "${HOME}/Pictures/profile#1.jpg"
curl -fL "${SELF_URL}/data/pictures/bliss.jpg" -o "${HOME}/Pictures/Bliss.jpg"

# [12.6] System Preferences > Desktop & Screen Saver > Desktop = Bliss.jpg
# [13.7] System Settings > Wallpaper > Bliss.jpg
# TODO Show on all Spaces = on
osascript -e "tell application \"System Events\" to tell every desktop to \
    set picture to \"${HOME}/Pictures/Bliss.jpg\" as POSIX file"

# Install the After Dark Flying Toasters replica screen saver
ZIPSRC="$(mktemp)"
if [ "$OS_MAJOR_VERSION" -le "13" ]; then
    curl -fL "${SELF_URL}/data/adftss.zip" -o "$ZIPSRC"
    unzip -uo "$ZIPSRC" -d "${HOME}/Library/Screen Savers"
    xattr -dr com.apple.quarantine "${HOME}/Library/Screen Savers/After Dark Flying Toasters.saver"
else
    curl -fL "${SELF_URL}/data/adftss2.zip" -o "$ZIPSRC"
    unzip -uo "$ZIPSRC" -d "${HOME}/Library/Screen Savers"
    xattr -dr com.apple.quarantine "${HOME}/Library/Screen Savers/Flying Toasters.saver"
fi

# Install Scottfiles
rm -rf "${HOME}/.scottfiles"
git clone https://github.com/smitelli/scottfiles.git "${HOME}/.scottfiles"
pushd "${HOME}/.scottfiles"
git remote set-url origin git@github.com:smitelli/scottfiles.git
stow aliases bash colors converters editor gdb git homebrew macos prompt tmux zsh
if [ "$INCLUDE_WORKTOOLS" = 'true' ]; then
    mkdir -p "${HOME}/bin"
    stow worktools
fi
popd

if [ "$INCLUDE_SOFTWARE_UPDATE" = 'true' ]; then
    # Install Rosetta on Apple silicon machines only
    if [ "$(uname -p)" = 'arm' ]; then
        softwareupdate --install-rosetta --agree-to-license
    fi

    # Install any software updates currently available
    # TODO partially disabled for now because I don't want the next macOS major version
    # softwareupdate --install --all
    softwareupdate --install --safari-only
fi

set -x

# ====================
# System Preferences /
# [13.0] System Settings
# ====================

# [12.5] General > Appearance = Dark
# [13.7] Appearance > Appearance = Dark
defaults write -g AppleInterfaceStyle -string 'Dark'

# [12.5] General > Accent color = Graphite
# [13.7] Appearance > Accent color = Graphite
# [12.5] General > Highlight color = Graphite
# [13.7] Appearance > Highlight color = Graphite
defaults write -g AppleAccentColor -int '-1'
defaults write -g AppleAquaColorVariant -int '6'
defaults write -g AppleHighlightColor -string '0.847059 0.847059 0.862745 Graphite'

# [13.7] Accessibility > Display > Reduce transparency = on
defaults write com.apple.universalaccess reduceTransparency -bool 'true'

# [12.5] Desktop & Screen Saver > Screen Saver > Show screen saver after ... = off (otherwise, 10 mins)
# [13.7] Lock Screen > Start Screen Saver when inactive = Never
defaults -currentHost write com.apple.screensaver idleTime -int '0'
defaults -currentHost write com.apple.screensaver lastDelayTime -int '600'

# [12.6] Desktop & Screen Saver > Screen Saver > Choose "After Dark: Flying Toasters"
# [13.7] Screen Saver > Choose "After Dark: Flying Toasters"
# TODO Show on all Spaces = on
if [ "$OS_MAJOR_VERSION" -le "13" ]; then
    defaults -currentHost write com.apple.screensaver moduleDict -dict \
        moduleName -string 'After Dark Flying Toasters' \
        path -string "${HOME}/Library/Screen Savers/After Dark Flying Toasters.saver" \
        type -int '0'
else
    # TODO doesn't work
    defaults -currentHost write com.apple.screensaver moduleDict -dict \
        moduleName -string 'Flying Toasters' \
        path -string "${HOME}/Library/Screen Savers/Flying Toasters.saver" \
        type -int '0'
fi

# [12.5] Desktop & Screen Saver > Screen Saver > Hot Corners... > Bottom Right = Disable Screen Saver
# [13.7] Desktop & Dock > Hot Corners... > Bottom Right = Disable Screen Saver
defaults write com.apple.dock wvous-br-corner -int '6'
defaults write com.apple.dock wvous-br-modifier -int '0'

# [12.5] Desktop & Screen Saver > Screen Saver > Hot Corners... > Bottom Left = Start Screen Saver
# [13.7] Desktop & Dock > Hot Corners... > Bottom Left = Start Screen Saver
defaults write com.apple.dock wvous-bl-corner -int '5'
defaults write com.apple.dock wvous-bl-modifier -int '0'

# [12.5] Dock & Menu Bar > Dock & Menu Bar > Automatically hide and show the Dock = on
# [13.7] Desktop & Dock > Dock > Automatically hide and show the Dock = on
defaults write com.apple.dock autohide -bool 'true'

# [12.5] Dock & Menu Bar > Dock & Menu Bar > Show recent applications in Dock = off
# [13.7] Desktop & Dock > Dock > Show recent applications in Dock = off
# [14.7] Desktop & Dock > Dock > Show suggested and recent apps in Dock = off
defaults write com.apple.dock show-recents -bool 'false'

# [13.7] Control Center > Control Center Modules > ...
    # Blank out any existing menu bar arrangement aside from the bare essentials
    defaults write com.apple.controlcenter '<dict>
        <key>NSStatusItem Visible Clock</key>
        <true/>
        <key>NSStatusItem Visible BentoBox</key>
        <true/>
    </dict>'
    sleep 2  # Paper over occasional unreliability here

    # Wi-Fi = Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter WiFi -int '2'
    defaults write com.apple.controlcenter 'NSStatusItem Visible WiFi' -bool 'true'

    # Bluetooth = Don't Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter Bluetooth -int '8'
    defaults write com.apple.controlcenter 'NSStatusItem Visible Bluetooth' -bool 'false'

    # AirDrop = Don't Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter AirDrop -int '8'
    defaults write com.apple.controlcenter 'NSStatusItem Visible AirDrop' -bool 'false'

    # Focus = Show When Active
    defaults -currentHost write com.apple.controlcenter FocusModes -int '2'
    defaults write com.apple.controlcenter 'NSStatusItem Visible FocusModes' -bool 'false'

    # Stage Manager = Don't Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter StageManager -int '8'
    defaults write com.apple.controlcenter 'NSStatusItem Visible StageManager' -bool 'false'

    # Screen Mirroring = Show When Active
    defaults -currentHost write com.apple.controlcenter ScreenMirroring -int '2'
    defaults write com.apple.controlcenter 'NSStatusItem Visible ScreenMirroring' -bool 'false'
    if [ "$OS_MAJOR_VERSION" -le "12" ]; then
        # [12.5] Dock & Menu Bar > Screen Mirroring > Show in Menu Bar = off
        defaults write com.apple.airplay showInMenuBarIfPresent -bool 'false'
    else
        defaults write com.apple.airplay showInMenuBarIfPresent -bool 'true'
    fi

    # Display = Don't Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter Display -int '8'
    defaults write com.apple.controlcenter 'NSStatusItem Visible Display' -bool 'false'

    # Sound = Always Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter Sound -int '18'
    defaults write com.apple.controlcenter 'NSStatusItem Visible Sound' -bool 'true'

    # Now Playing = Show When Active
    defaults -currentHost write com.apple.controlcenter NowPlaying -int '2'
    defaults write com.apple.controlcenter 'NSStatusItem Visible NowPlaying' -bool 'false'

# [13.7] Control Center > Other Modules > ...
    # Accessibility Shortcuts = Show in Menu Bar = off; Show in Control Center = off
    defaults -currentHost write com.apple.controlcenter AccessibilityShortcuts -int '12'
    defaults write com.apple.controlcenter 'NSStatusItem Visible AccessibilityShortcuts' -bool 'false'

    # Battery = Show in Menu Bar = on; Show in Control Center = off; Show Percentage = on
    defaults -currentHost write com.apple.controlcenter Battery -int '6'
    defaults write com.apple.controlcenter 'NSStatusItem Visible Battery' -bool 'true'
    defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool 'true'

    if [ "$OS_MAJOR_VERSION" -ge "14" ]; then
        # [14.7] Music Recognition = Show in Menu Bar = off; Show in Control Center = off
        defaults -currentHost write com.apple.controlcenter MusicRecognition -int '12'
        defaults write com.apple.controlcenter 'NSStatusItem Visible MusicRecognition' -bool 'false'
    fi

    # Hearing = Show in Menu Bar = off; Show in Control Center = off
    defaults -currentHost write com.apple.controlcenter Hearing -int '12'
    defaults write com.apple.controlcenter 'NSStatusItem Visible Hearing' -bool 'false'

    # Fast User Switching = Show in Menu Bar = Don't Show; Show in Control Center = off
    defaults -currentHost write com.apple.controlcenter UserSwitcher -int '12'
    defaults write com.apple.controlcenter 'NSStatusItem Visible UserSwitcher' -bool 'false'

    # Keyboard Brightness = Show in Menu Bar = off; Show in Control Center = off
    defaults -currentHost write com.apple.controlcenter KeyboardBrightness -int '12'
    defaults write com.apple.controlcenter 'NSStatusItem Visible KeyboardBrightness' -bool 'false'

# [13.7] Control Center > Menu Bar Only > ...
    # Spotlight = Don't Show in Menu Bar
    defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool 'true'

    # Siri = Don't Show in Menu Bar
    defaults -currentHost write com.apple.controlcenter Siri -int '8'
    Defaults write com.apple.Siri StatusMenuVisible -bool 'false'

# [13.7] Menu bar sort: [focus] [mirroring] [now playing] [battery] [wi-fi] [sound] [bento] [clock]
sleep 2
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position BentoBox' -int '128'
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position Sound' -int '160'
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position WiFi' -int '192'
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position Battery' -int '224'
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position NowPlaying' -int '256'
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position ScreenMirroring' -int '288'
defaults write com.apple.controlcenter 'NSStatusItem Preferred Position FocusModes' -int '320'
sleep 2

killall ControlCenter
sleep 2

if [ "$OS_MAJOR_VERSION" -le "12" ]; then
    # [12.5] Dock & Menu Bar > Clock > Show date = never
    defaults write com.apple.menuextra.clock DateFormat -string 'EEE h:mm:ss a'
else
    # [13.2] Control Center > Menu Bar Only > Clock Options... > Date > Show date = Never
    defaults write com.apple.menuextra.clock ShowDate -int '2'
fi

# [12.5] Dock & Menu Bar > Clock > Display the time with seconds = on
# [13.7] Control Center > Menu Bar Only > Clock Options... > Time > Display the time with seconds = on
defaults write com.apple.menuextra.clock ShowSeconds -bool 'true'

# [12.5] Notifications & Focus > Notifications > Allow notifications when the display is sleeping = on
# [13.7] Notifications > Notification Center > ...
#   - Allow notifications when the display is sleeping = on
#   - Allow notifications when the screen is locked = off
#   - Allow notifications when mirroring or sharing the display = off
PLIST='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>dndDisplayLock</key>
    <true/>
    <key>dndDisplaySleep</key>
    <false/>
    <key>dndMirrored</key>
    <true/>
    <key>facetimeCanBreakDND</key>
    <false/>
    <key>playSoundsForForwardedNotifications</key>
    <true/>
    <key>repeatedFacetimeCallsBreaksDND</key>
    <false/>
    <key>summarizeNotifications</key>
    <true/>
</dict>
</plist>'
defaults write com.apple.ncprefs dnd_prefs "$(_make_bplist "$PLIST")"

# [12.6] Users & Groups > [self] > Edit profile picture
# Cherry-picked from https://apple.stackexchange.com/a/432510
dscl . -delete "/Users/$(logname)" Picture
dscl . -delete "/Users/$(logname)" JPEGPhoto
RECORD="$(mktemp)"
echo -e "0x0A 0x5C 0x3A 0x2C dsRecTypeStandard:Users 2 dsAttrTypeStandard:RecordName externalbinary:dsAttrTypeStandard:JPEGPhoto\n$(logname):${HOME}/Pictures/profile.jpg" > "$RECORD"
sudo dsimport "$RECORD" /Local/Default M

# [12.6] Security & Privacy > General > Show a message when the screen is locked = on
# [12.6] Security & Privacy > General > Set Lock Message...
# [13.7] Lock Screen > Show message when locked = on
# [13.7] Lock Screen > Show message when locked > Set...
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText \
    "'If found, please contact:\nscott@smitelli.com\n+1 (909) 764-8354'"

if [ "$OS_MAJOR_VERSION" -le "12" ]; then
    # [12.6] Security & Privacy > Firewall > Turn On Firewall
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int '1'
    sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null
else
    # [13.7] Network > Firewall > on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
fi

# [12.5] Security & Privacy > Privacy > Apple Advertising > Personalized Ads = off
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool 'false'
defaults write com.apple.AdLib adprivacydSegmentInterval -string "$RANDOM"

# [12.5] Sound > Output volume = 55%
osascript -e 'set volume output volume 55'

# [12.6] Sound > Sound Effects > Play sound on startup = off
sudo nvram StartupMute=%01

# [12.5] Sound > Input > Input volume = 75%
osascript -e 'set volume input volume 75'

# [13.7] Keyboard > Key repeat rate = 7/7
defaults write -g KeyRepeat -int '2'

# [13.7] Keyboard > Delay until repeat = 4/5
defaults write -g InitialKeyRepeat -int '25'

# [12.5] Keyboard > Press fn/Globe key to = Do Nothing
defaults write com.apple.HIToolbox AppleFnUsageType -int '0'

# [12.6] Keyboard > Keyboard > Customize Control Strip
# [13.7] Keyboard > Touch Bar Settings... > Customize Control Strip...
defaults write com.apple.controlstrip FullCustomized -array \
    -string 'com.apple.system.group.brightness' \
    -string 'com.apple.system.mission-control' \
    -string 'com.apple.system.launchpad' \
    -string 'com.apple.system.group.keyboard-brightness' \
    -string 'com.apple.system.group.media' \
    -string 'com.apple.system.group.volume'
defaults write com.apple.controlstrip MiniCustomized -array \
    -string 'com.apple.system.brightness' \
    -string 'com.apple.system.volume' \
    -string 'com.apple.system.mute' \
    -string 'com.apple.system.screen-lock'

# Keyboard > Text > Remove "omw" replacement (TODO bugged)
defaults write com.apple.textInput.keyboardServices.textReplacement KSDidPushMigrationStatusOnce-2 -bool 'true'
defaults write com.apple.textInput.keyboardServices.textReplacement KSSampleShortcutWasImported_CK -bool 'true'
defaults write -g NSUserDictionaryReplacementItems '()'

# [12.6] Keyboard > Shortcuts > Use keyboard navigation to move focus between controls = on
# [13.7] Keyboard > Keyboard navigation = on
# TODO Figure out differences between 2 (from SysPrefs) and 3 (from randos)
defaults write -g AppleKeyboardUIMode -int '3'

# [12.5] Keyboard > Text > Correct spelling automatically = off
# [13.7] Keyboard > Text Input > Input Sources > Edit... > All Input Sources > Correct spelling automatically = off
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool 'false'
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool 'false'

# [12.5] Keyboard > Text > Capitalize words automatically = off
# [13.7] Keyboard > Text Input > Input Sources > Edit... > All Input Sources > Capitalize words automatically = off
defaults write -g NSAutomaticCapitalizationEnabled -bool 'false'

if [ "$OS_MAJOR_VERSION" -ge "14" ]; then
    # [14.7] Keyboard > Text Input > Input Sources > Edit... > All Input Sources > Show inline predictive text = off
    defaults write -g NSAutomaticInlinePredictionEnabled -bool 'false'
fi

# [12.5] Keyboard > Text > Add period with double-space = off
# [13.7] Keyboard > Text Input > Input Sources > Edit... > All Input Sources > Add period with double-space = off
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool 'false'

# [12.5] Keyboard > Text > Use smart quotes and dashes = off
# [13.7] Keyboard > Text Input > Input Sources > Edit... > All Input Sources > Use smart quotes and dashes = off
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool 'false'
defaults write -g NSAutomaticDashSubstitutionEnabled -bool 'false'

# [12.6] Keyboard > Text > Touch Bar typing suggestions = off
# [13.7] Keyboard > Touch Bar Settings > Show typing suggestions = off
defaults write -g NSAutomaticTextCompletionEnabled -bool 'false'

# [12.6] Trackpad > Point & Click > Tap to click = on
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool 'true'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool 'true'
defaults -currentHost write -g com.apple.mouse.tapBehavior -int '1'

# [12.5] Trackpad > Point & Click > Tracking speed = 5/9
defaults write -g com.apple.trackpad.scaling -float '1'

# [12.5] Trackpad > More Gestures > App Exposé = on
defaults write com.apple.dock showAppExposeGestureEnabled -bool 'true'

# [12.5] Battery > Battery > Turn display off after = 10m
# [13.7] Lock Screen > Turn display off on battery when inactive = For 10 minutes
sudo pmset -b displaysleep 10

# [12.5] Battery > Power Adapter > Turn display off after = Never
# [13.7] Lock Screen > Turn display off on power adapter when inactive = Never
sudo pmset -c displaysleep 0

# [12.5] Battery > Power Adapter > Prevent your Mac from automatically sleeping when the display is off = on
# [13.7] Displays > Advanced... > Prevent automatic sleeping on power adapter when the display is off = on
# [14.7] Battery > Options > Prevent automatic sleeping on power adapter when the display is off = on
sudo pmset -c sleep 0

# [12.5] Sharing > Computer Name = ...
# [13.7] General > About > Name
# [13.7] General > Sharing > Local hostname > Edit...
sudo scutil --set LocalHostName "$SET_HOSTNAME"
sudo scutil --set ComputerName "$SET_HOSTNAME"
dscacheutil -flushcache

if [ "$OS_MAJOR_VERSION" -le "12" ]; then
    # [12.5] Sharing > AirPlay Receiver = off
    defaults -currentHost write com.apple.controlcenter AirplayRecieverEnabled -bool 'false'
fi

# [12.6] Apple Menu > {Restart,Shut Down}... > Reopen windows when logging back in = off
defaults write com.apple.loginwindow TALLogoutSavesState -bool 'false'

# [12.6] UNDOCUMENTED > Expand save dialogs by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool 'true'

# [12.6] UNDOCUMENTED > Expand print dialogs by default
defaults write -g PMPrintingExpandedStateForPrint2 -bool 'true'

# [12.6] UNDOCUMENTED > Max out the amount of time that must pass before Touch ID needs the password
sudo bioutil --system --write --timeout 172800

# ====================
# Finder
# ====================

# [12.5] Preferences > General > Show these items on the desktop > Hard disks = on
# [13.7] Settings > General > Show these items on the desktop > Hard disks = on
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool 'true'

# [12.5] Preferences > General > Show these items on the desktop > Connected servers = on
# [13.7] Settings > General > Show these items on the desktop > Connected servers = on
defaults write com.apple.finder ShowMountedServersOnDesktop -bool 'true'

# [12.5] Preferences > General > New finder windows show = home directory
# [13.7] Settings > General > New finder windows show = home directory
defaults write com.apple.finder NewWindowTarget -string 'PfHm'
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# [12.5] Preferences > Sidebar > Show these items in the sidebar > Favorites
# [13.7] Settings > Sidebar > Show these items in the sidebar > Favorites
mysides remove all
mysides add Applications 'file:///Applications/'
mysides add "$(logname)" "file://${HOME}/"
mysides add Desktop "file://${HOME}/Desktop/"
mysides add Documents "file://${HOME}/Documents/"
mysides add Downloads "file://${HOME}/Downloads/"
mysides add Movies "file://${HOME}/Movies/"
mysides add Music "file://${HOME}/Music/"
mysides add Pictures "file://${HOME}/Pictures/"

# [12.5] Preferences > Sidebar > Show these items in the sidebar > Tags > Recent Tags = off
# [13.7] Settings > Sidebar > Show these items in the sidebar > Tags > Recent Tags = off
defaults write com.apple.finder ShowRecentTags -bool 'false'

# [12.5] Preferences > Advanced > Show all filename extensions = on
# [13.7] Settings > Advanced > Show all filename extensions = on
defaults write -g AppleShowAllExtensions -bool 'true'

# [12.5] Preferences > Advanced > Keep folders on top > In windows when sorting by name = on
# [13.7] Settings > Advanced > Keep folders on top > In windows when sorting by name = on
defaults write com.apple.finder _FXSortFoldersFirst -bool 'true'

# [12.5] Preferences > Advanced > When performing a search = Search the Current Folder
# [13.7] Settings > Advanced > When performing a search = Search the Current Folder
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'

# [12.6] File > Get Info > Expand General, More Info, Name & Extension, Comments,
#        Open with, Preview, Sharing & Permissions.
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool 'true' \
    MetaData -bool 'true' \
    Name -bool 'true' \
    Comments -bool 'true' \
    OpenWith -bool 'true' \
    Preview -bool 'true' \
    Privileges -bool 'true'

# [12.5] View > as Columns
defaults write com.apple.finder FXPreferredViewStyle -string 'clmv'

# [12.5] View > Sort By = Name
/usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
/usr/libexec/PlistBuddy -c 'Set :FK_StandardViewSettings:IconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
/usr/libexec/PlistBuddy -c 'Set :StandardViewSettings:IconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
/usr/libexec/PlistBuddy -c 'Set :StandardViewSettings:GalleryViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"

# [12.6] UNDOCUMENTED > Delay before showing folder icon in window toolbars (sec)
defaults write -g NSToolbarTitleViewRolloverDelay -float 0.5

# [12.6] UNDOCUMENTED > Disable warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool 'false'

# [12.6] UNDOCUMENTED > Disable writing .DS_Store files on network shares
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool 'true'

# [12.6] UNDOCUMENTED > Disable writing .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool 'true'

# [12.6] UNDOCUMENTED > Delay before showing tooltips (ms)
defaults write -g NSInitialToolTipDelay -int 500

killall Finder

# ====================
# Dock
# ====================

# [12.5] Remove all apps and recents from Dock
defaults delete com.apple.dock.extra || true  # [12.5] doesn't exist on fresh install
defaults write com.apple.dock persistent-apps '()'
defaults write com.apple.dock persistent-others '()'
defaults write com.apple.dock recent-apps '()'

killall Dock

# ====================
# Calculator
# ====================

if [ "$OS_MAJOR_VERSION" -le "14" ]; then
    # [12.5] View > Scientific
    defaults write com.apple.calculator ViewDefaultsKey -string 'Scientific'
else
    # [15.0] View > Scientific
    defaults write com.apple.calculator CalculatorMode -string 'scientific'
fi

# [12.5] View > Show Thousands Separators
defaults write com.apple.calculator SeparatorsDefaultsKey -bool 'true'

# ====================
# Contacts
# ====================

# [14.7] Settings > General > Sort By = First Name
defaults write com.apple.AddressBook ABNameSortingFormat -string 'sortingFirstName sortingLastName'

# ====================
# Disk Utility
# ====================

# [12.5] Rename APFS disks to "[Hostname]" and "[Hostname] Data"
diskutil rename / "$DISKNAME"
diskutil rename /System/Volumes/Data "${DISKNAME} Data"

# [12.5] View > Show All Devices
defaults write com.apple.DiskUtility SidebarShowAllDevices -bool 'true'

# [12.5] View > Show APFS Snapshots
defaults write com.apple.DiskUtility WorkspaceShowAPFSSnapshots -bool 'true'

# ====================
# Font Book
# ====================

if [ "$OS_MAJOR_VERSION" -le "12" ]; then
    # [12.5] Preferences > Default Install Location = Computer
    defaults write com.apple.FontBook FBDefaultInstallDomainRef -int '1'
else
    # [13.7] Settings > Installation > Default install location = All Users
    defaults write com.apple.FontBook installLocation -int '-2'
fi

# ====================
# Safari
# ====================

# [16.6] Settings > Advanced > Show features for web developers
defaults write com.apple.Safari IncludeDevelopMenu -bool 'true'
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool 'true'
defaults write com.apple.Safari WebKitPreferences.developerExtrasEnabled -bool 'true'
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool 'true'

# ====================
# Screenshot
# ====================

# [12.6] Save screenshots to the clipboard
defaults write com.apple.screencapture target -string 'clipboard'

# ====================
# SSH Client
# ====================

# Generate fresh SSH keys for this user on this computer
ssh-keygen -N '' -C "$(logname)@${SET_HOSTNAME}" -f "${HOME}/.ssh/id_rsa" -t rsa -b 3072
ssh-keygen -N '' -C "$(logname)@${SET_HOSTNAME}" -f "${HOME}/.ssh/id_ecdsa" -t ecdsa -b 521
ssh-keygen -N '' -C "$(logname)@${SET_HOSTNAME}" -f "${HOME}/.ssh/id_ed25519" -t ed25519

# ====================
# Terminal
# ====================

# [12.5] Install "Basic Custom" profile
PROFILE_NAME='Basic Custom'
BGCOLOR="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>\$archiver</key>
    <string>NSKeyedArchiver</string>
    <key>\$objects</key>
    <array>
        <string>\$null</string>
        <dict>
            <key>\$class</key>
            <dict>
                <key>CF\$UID</key>
                <integer>2</integer>
            </dict>
            <key>NSColorSpace</key>
            <integer>1</integer>
            <key>NSRGB</key>
            <data>$(printf '0 0 0\0' | base64)</data>
        </dict>
        <dict>
            <key>\$classes</key>
            <array>
                <string>NSColor</string>
                <string>NSObject</string>
            </array>
            <key>\$classname</key>
            <string>NSColor</string>
        </dict>
    </array>
    <key>\$top</key>
    <dict>
        <key>root</key>
        <dict>
            <key>CF\$UID</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>\$version</key>
    <integer>100000</integer>
</dict>
</plist>"
CURCOLOR="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>\$archiver</key>
    <string>NSKeyedArchiver</string>
    <key>\$objects</key>
    <array>
        <string>\$null</string>
        <dict>
            <key>\$class</key>
            <dict>
                <key>CF\$UID</key>
                <integer>2</integer>
            </dict>
            <key>NSColorSpace</key>
            <integer>1</integer>
            <key>NSRGB</key>
            <data>$(printf '0 0.7529411765 0\0' | base64)</data>
        </dict>
        <dict>
            <key>\$classes</key>
            <array>
                <string>NSColor</string>
                <string>NSObject</string>
            </array>
            <key>\$classname</key>
            <string>NSColor</string>
        </dict>
    </array>
    <key>\$top</key>
    <dict>
        <key>root</key>
        <dict>
            <key>CF\$UID</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>\$version</key>
    <integer>100000</integer>
</dict>
</plist>"
# shellcheck disable=SC2016
FONT='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>$archiver</key>
    <string>NSKeyedArchiver</string>
    <key>$objects</key>
    <array>
        <string>$null</string>
        <dict>
            <key>$class</key>
            <dict>
                <key>CF$UID</key>
                <integer>3</integer>
            </dict>
            <key>NSName</key>
            <dict>
                <key>CF$UID</key>
                <integer>2</integer>
            </dict>
            <key>NSSize</key>
            <real>12</real>
            <key>NSfFlags</key>
            <integer>16</integer>
        </dict>
        <string>Consolas</string>
        <dict>
            <key>$classes</key>
            <array>
                <string>NSFont</string>
                <string>NSObject</string>
            </array>
            <key>$classname</key>
            <string>NSFont</string>
        </dict>
    </array>
    <key>$top</key>
    <dict>
        <key>root</key>
        <dict>
            <key>CF$UID</key>
            <integer>1</integer>
        </dict>
    </dict>
    <key>$version</key>
    <integer>100000</integer>
</dict>
</plist>'
defaults write com.apple.Terminal 'Window Settings' -dict-add "$PROFILE_NAME" "<dict>
    <key>name</key>
    <string>$PROFILE_NAME</string>
    <key>BackgroundBlur</key>
    <real>0.0</real>
    <key>CursorBlink</key>
    <true/>
    <key>FontAntialias</key>
    <true/>
    <key>FontWidthSpacing</key>
    <integer>1</integer>
    <key>ProfileCurrentVersion</key>
    <real>2.0699999999999998</real>
    <key>WindowTitle</key>
    <string>Terminal</string>
    <key>columnCount</key>
    <integer>80</integer>
    <key>rowCount</key>
    <integer>50</integer>
    <key>shellExitAction</key>
    <integer>1</integer>
    <key>type</key>
    <string>Window Settings</string>
    <key>useOptionAsMetaKey</key>
    <true/>
    <key>BackgroundColor</key>
    $(_make_bplist "$BGCOLOR")
    <key>CursorColor</key>
    $(_make_bplist "$CURCOLOR")
    <key>Font</key>
    $(_make_bplist "$FONT")
</dict>"

# [12.5] Preferences > General > On startup, open new window with profile = [profile]
# [13.7] Settings > General > On startup, open new window with profile = [profile]
defaults write com.apple.Terminal 'Startup Window Settings' -string "$PROFILE_NAME"

# [12.5] Preferences > Profiles > Set [profile] as Default
# [13.7] Settings > Profiles > Set [profile] as Default
defaults write com.apple.Terminal 'Default Window Settings' -string "$PROFILE_NAME"

# [12.6] View > Hide Marks
defaults write com.apple.Terminal ShowLineMarks -bool 'false'

# ====================
# Additional Applications
# ====================

# Install common apps
brew install --no-quarantine firefox git-lfs keepassxc sublime-text vlc
if [ "$USES_OPENCORE" = 'true' ]; then
    brew install --no-quarantine opencore-patcher
fi
if [ "$INCLUDE_WORKTOOLS" = 'true' ]; then
    brew install --no-quarantine amazon-chime homebrew/cask/docker google-chrome zoom
else
    brew install --no-quarantine obsidian
fi

# Install some useful Quick Look plugins
# TODO qlvideo would be nice but I can't figure out why it doesn't work
brew install --no-quarantine qlmarkdown syntax-highlight
xattr -dr com.apple.quarantine "${HOME}"/Library/QuickLook/*.qlgenerator
qlmanage -r
qlmanage -r cache

# Add preferred apps to the Dock in order
[ -e '/Applications/Google Chrome.app' ] &&  dockutil --no-restart --add '/Applications/Google Chrome.app'
dockutil --no-restart --add '/Applications/Firefox.app'
dockutil --no-restart --add '/System/Applications/Utilities/Terminal.app'
dockutil --no-restart --add '/Applications/Sublime Text.app'
[ -e '/Applications/Obsidian.app' ] &&  dockutil --no-restart --add '/Applications/Obsidian.app'
dockutil --no-restart --add '/Applications/KeePassXC.app'
dockutil --no-restart --add '/Applications/VLC.app'
[ -e '/Applications/Amazon Chime.app' ] &&  dockutil --no-restart --add '/Applications/Amazon Chime.app'
[ -e '/Applications/Docker.app' ] &&  dockutil --no-restart --add '/Applications/Docker.app'
[ -e '/Applications/zoom.us.app' ] &&  dockutil --no-restart --add '/Applications/zoom.us.app'
dockutil --no-restart --add '/System/Applications/Calculator.app'
dockutil --no-restart --add '/System/Applications/Utilities/Screenshot.app'
dockutil --no-restart --add '/System/Applications/Utilities/Activity Monitor.app'

killall Dock

# ====================
# Amazon Chime (if installed)
# ====================

if [ -e '/Applications/Amazon Chime.app' ]; then
    # [4.39] First Run > Check for updates automatically? = Check Automatically
    defaults write com.amazon.Amazon-Chime SUEnableAutomaticChecks -bool 'true'
    defaults write com.amazon.Amazon-Chime SUHasLaunchedBefore -bool 'true'
fi

# ====================
# KeePassXC
# ====================

if [ -e '/Applications/KeePassXC.app' ]; then
    # Install skeleton INI files to initialize configuration
    curl -fL --create-dirs "${SELF_URL}/keepassxc/application-support.ini" -o "${HOME}/Library/Application Support/KeePassXC/keepassxc.ini"
    curl -fL --create-dirs "${SELF_URL}/keepassxc/caches.ini" -o "${HOME}/Library/Caches/KeePassXC/keepassxc.ini"
fi

# ====================
# VLC
# ====================

if [ -e '/Applications/VLC.app' ]; then
    # [3.0.17] First Run > Check for album art and metadata? > [don't care enough here]
    defaults write org.videolan.vlc VLCFirstRun -string "$(date -u '+%Y-%m-%d %H:%M:%S %z')"

    # [3.0.17] First Run > Check for updates automatically? = Check Automatically
    defaults write org.videolan.vlc SUEnableAutomaticChecks -bool 'true'
    defaults write org.videolan.vlc SUHasLaunchedBefore -bool 'true'
fi

# ====================
# QLMarkdown
# ====================

if [ -e '/Applications/QLMarkdown.app' ]; then
    # [1.0] First Run > Check for updates automatically? = Check Automatically
    defaults write org.sbarex.QLMarkdown SUEnableAutomaticChecks -bool 'true'
    defaults write org.sbarex.QLMarkdown SUHasLaunchedBefore -bool 'true'

    # [1.0] App must be started at least once to register its plugin (ugh)
    open -g '/Applications/QLMarkdown.app' && sleep 5 && osascript -e 'quit app "QLMarkdown"'
fi

# ====================
# Syntax Highlight
# ====================

if [ -e '/Applications/Syntax Highlight.app' ]; then
    # [2.1.24] First Run > Check for updates automatically? = Check Automatically
    defaults write org.sbarex.SourceCodeSyntaxHighlight SUEnableAutomaticChecks -bool 'true'
    defaults write org.sbarex.SourceCodeSyntaxHighlight SUHasLaunchedBefore -bool 'true'

    # [2.1.24] App must be started at least once to register its plugin (ugh)
    open -g '/Applications/Syntax Highlight.app' && sleep 5 && osascript -e 'quit app "Syntax Highlight"'
fi

# ====================
# Clean up
# ====================

# Remove Zsh stuff that isn't going to be used anymore
rm -rf "${HOME}"/.zsh_{history,sessions}

# ====================
# Hope real hard that it all worked
# ====================

# Delay shutdown to ensure entire session flushes out
sudo shutdown -r +1
