#!/bin/bash -e

# defaults read > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(defaults read)
# defaults -currentHost read > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(defaults -currentHost read)
# find /Library/Preferences -type f -exec defaults read '{}' \; > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(find /Library/Preferences -type f -exec defaults read '{}' \;)
# F=$(mktemp); cp ~/Library/Preferences/com.apple.Terminal.plist "$F"; plutil -convert xml1 "$F"; less -S "$F"

# TODO touch bar

# External customizations
SET_HOSTNAME="${SET_HOSTNAME:-$(scutil --get ComputerName)}"
CAPITALIZE_DISK="${CAPITALIZE_DISK:-true}"

# Make a base64-encoded blob containing a binary plist.
# $1: Complete XML-readable plist document.
# Returns a string like "<data>AA...A=</data>".
_make_bplist() {
    local PLIST=$(mktemp)

    echo "$1" > "$PLIST"
    plutil -convert binary1 "$PLIST"
    echo "<data>$(base64 "$PLIST")</data>"
    rm -f "$PLIST"
}

# ====================
# Initialization
# ====================

# Ask for the administrator password at the very beginning...
sudo -v

# ... and refresh it every 60 seconds until the script exits.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Add /usr/libexec to the $PATH temporarily to make it cleaner to run PlistBuddy
PATH="$PATH:/usr/libexec"

# ====================
# Installations
# ====================

# Install Homebrew
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install utilities that are required for this script
brew install git mysides stow

# Install dockutil
# TODO This can be done with brew when they get around to making a v3 forumula
PKG=$(mktemp)
curl -fL 'https://github.com/kcrawford/dockutil/releases/download/3.0.2/dockutil-3.0.2.pkg' -o "$PKG"
sudo installer -verboseR -pkg "$PKG" -target /

# Install Consolas font family system-wide
curl -fL 'https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD/data/consola{,b,i,z}.ttf' -o '/Library/Fonts/consola#1.ttf'

# Install user profile and background banner images
curl -fL 'https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD/data/profile{,-bg}.jpg' -o "${HOME}/Pictures/profile#1.jpg"

# Install the After Dark Flying Toasters replica screen saver
ZIPSRC=$(mktemp)
curl -fL 'https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD/data/adftss.zip' -o "$ZIPSRC"
unzip -uo "$ZIPSRC" -d "${HOME}/Library/Screen Savers/"
xattr -dr com.apple.quarantine "${HOME}/Library/Screen Savers/After Dark Flying Toasters.saver"

# Install Scottfiles
rm -rf "${HOME}/.scottfiles"
git clone https://github.com/smitelli/scottfiles.git "${HOME}/.scottfiles"
pushd "${HOME}/.scottfiles"
stow aliases bash colors converters editor gdb homebrew macos prompt tmux
popd

# Install Rosetta on Apple silicon machines only
if [ $(uname -p) = 'arm' ]; then
    softwareupdate --install-rosetta --agree-to-license
fi

set -x

# ====================
# System Preferences
# ====================

<<COMMENT
- General
-- Default web browser

- Internet Accounts

- Security & Privacy
-- General
--- Require password ... = immediately
-- FileVault
--- Turn On
-- Privacy
--- Location Services
---- System Services > Details...
----- Allow [Find My Mac] to determine your location = on

- Software Update

- Network
-- Delete Thunderbolt Bridge

- Touch ID
-- Add at least 2 index fingers

- Apple ID
-- iCloud
--- Allow Find My Mac
COMMENT

# [12.5] General > Appearance = Dark
defaults write -g AppleInterfaceStyle -string 'Dark'

# [12.5] General > Accent color = Graphite
# [12.5] General > Highlight color = Graphite
defaults write -g AppleAccentColor -int '-1'
defaults write -g AppleAquaColorVariant -int '6'
defaults write -g AppleHighlightColor -string '0.847059 0.847059 0.862745 Graphite'

# Desktop & Screen Saver > Desktop (TODO test)
osascript -e 'tell application "System Events" to tell every desktop to set picture to "/System/Library/Desktop Pictures/Solid Colors/Black.png" as POSIX file'

# [12.5] Desktop & Screen Saver > Screen Saver > Show screen saver after ... = off (otherwise, 10 mins)
defaults -currentHost write com.apple.screensaver idleTime -int '0'
defaults -currentHost write com.apple.screensaver lastDelayTime -int '600'

# Desktop & Screen Saver > Screen Saver > Choose "After Dark Flying Toasters" (TODO test)
defaults -currentHost write com.apple.screensaver moduleDict "<dict>
    <key>moduleName</key>
    <string>After Dark Flying Toasters</string>
    <key>path</key>
    <string>${HOME}/Library/Screen Savers/After Dark Flying Toasters.saver</string>
    <key>type</key>
    <integer>0</integer>
</dict>"

# [12.5] Desktop & Screen Saver > Screen Saver > Hot Corners... > Bottom Right = Disable Screen Saver
defaults write com.apple.dock wvous-br-corner -int '6'
defaults write com.apple.dock wvous-br-modifier -int '0'

# [12.5] Desktop & Screen Saver > Screen Saver > Hot Corners... > Bottom Left = Start Screen Saver
defaults write com.apple.dock wvous-bl-corner -int '5'
defaults write com.apple.dock wvous-bl-modifier -int '0'

# [12.5] Dock & Menu Bar > Dock & Menu Bar > Automatically hide and show the Dock = on
defaults write com.apple.dock autohide -bool 'true'

# [12.5] Dock & Menu Bar > Dock & Menu Bar > Show recent applications in Dock = off
defaults write com.apple.dock show-recents -bool 'false'

# [12.5] Dock & Menu Bar > Screen Mirroring > Show in Menu Bar = off
defaults write com.apple.airplay showInMenuBarIfPresent -bool 'false'

# [12.5] Dock & Menu Bar > Sound > Show in Menu Bar = always
defaults -currentHost write com.apple.controlcenter Sound -int '16'

# [12.5] Dock & Menu Bar > Battery > Show Percentage = on
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool 'true'

# [12.5] Dock & Menu Bar > Clock > Show date = never
defaults write com.apple.menuextra.clock DateFormat -string 'EEE h:mm:ss a'

# [12.5] Dock & Menu Bar > Clock > Display the time with seconds = on
defaults write com.apple.menuextra.clock ShowSeconds -bool 'true'

# [12.5] Dock & Menu Bar > Spotlight > Show in Menu Bar = off
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool 'true'

# [12.5] Dock & Menu Bar > Sound > Show in Menu Bar = on
# [12.5] Dock & Menu Bar > Wi-Fi > Show in Menu Bar = on
# [12.5] Dock & Menu Bar > Battery > Show in Menu Bar = on
# [12.5] Order = [focus] [display] [battery] [wi-fi] [sound] [bento] [clock]
defaults write com.apple.controlcenter '<dict>
    <key>NSStatusItem Preferred Position BentoBox</key>
    <real>128</real>
    <key>NSStatusItem Preferred Position Sound</key>
    <real>160</real>
    <key>NSStatusItem Preferred Position WiFi</key>
    <real>192</real>
    <key>NSStatusItem Preferred Position Battery</key>
    <real>224</real>
    <key>NSStatusItem Preferred Position Display</key>
    <real>256</real>
    <key>NSStatusItem Preferred Position FocusModes</key>
    <real>288</real>
    <key>NSStatusItem Visible Clock</key>
    <true/>
    <key>NSStatusItem Visible BentoBox</key>
    <true/>
    <key>NSStatusItem Visible Sound</key>
    <true/>
    <key>NSStatusItem Visible WiFi</key>
    <true/>
    <key>NSStatusItem Visible Battery</key>
    <true/>
    <key>NSStatusItem Visible Display</key>
    <false/>
    <key>NSStatusItem Visible FocusModes</key>
    <false/>
</dict>'

# [12.5] Notifications & Focus > Notifications > Allow notifications when the display is sleeping = on
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
    <key>repeatedFacetimeCallsBreaksDND</key>
    <false/>
</dict>
</plist>'
defaults write com.apple.ncprefs dnd_prefs "$(_make_bplist "$PLIST")"

# Users & Groups > [self] > Edit profile picture
# Cherry-picked from https://apple.stackexchange.com/a/432510
dscl . -delete "/Users/$(logname)" Picture
dscl . -delete "/Users/$(logname)" JPEGPhoto
RECORD="$(mktemp)"
echo -e "0x0A 0x5C 0x3A 0x2C dsRecTypeStandard:Users 2 dsAttrTypeStandard:RecordName base64:dsAttrTypeStandard:JPEGPhoto\n$(logname):${HOME}/Pictures/profile.jpg" > "$RECORD"
dsimport "$RECORD" /Local/Default M

# [12.5] Users & Groups > [self] > Advanced Options... > Login shell = /bin/bash
sudo chsh -s /bin/bash $(logname)

# Security & Privacy > Firewall > Turn On Firewall (TODO test)
sudo defaults write /Library/Preferences/com.apple.alf.plist globalstate -int '1'

# [12.5] Security & Privacy > Privacy > Apple Advertising > Personalized Ads = off
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool 'false'
defaults write com.apple.AdLib adprivacydSegmentInterval -string "$RANDOM"

# [12.5] Sound > Output volume = 55%
osascript -e 'set volume output volume 55'

# [12.5] Sound > Input > Input volume = 75%
osascript -e 'set volume input volume 75'

# [12.5] Keyboard > Keyboard > Key repeat = 7/7
defaults write -g KeyRepeat -int '2'

# [12.5] Keyboard > Keyboard > Delay Until Repeat = 4/5
defaults write -g InitialKeyRepeat -int '25'

# [12.5] Keyboard > Keyboard > Press fn/Globe key to = Do Nothing
defaults write com.apple.HIToolbox AppleFnUsageType -int '0'

# Keyboard > Text > Remove "omw" replacement (TODO keeps coming back)
defaults write -g NSUserDictionaryReplacementItems '()'

# [12.5] Keyboard > Text > Correct spelling automatically = off
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool 'false'
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool 'false'

# [12.5] Keyboard > Text > Capitalize words automatically = off
defaults write -g NSAutomaticCapitalizationEnabled -bool 'false'

# [12.5] Keyboard > Text > Add period with double-space = off
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool 'false'

# [12.5] Keyboard > Text > Use smart quotes and dashes = off
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool 'false'
defaults write -g NSAutomaticDashSubstitutionEnabled -bool 'false'

# Keyboard > Shortcuts > Use keyboard navigation to move focus between controls = on
# TODO Figure out differences between 2 (from SysPrefs) and 3 (from randos)
defaults write -g AppleKeyboardUIMode -int '3'

# Trackpad > Point & Click > Tap to click = on (TODO test)
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool 'true'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool 'true'
defaults write -g com.apple.mouse.tapBehavior -int '1'
defaults -currentHost write -g com.apple.mouse.tapBehavior -int '1'

# [12.5] Trackpad > Point & Click > Tracking speed = 5/9
defaults write -g com.apple.trackpad.scaling -float '1'

# [12.5] Trackpad > More Gestures > App Exposé = on
defaults write com.apple.dock showAppExposeGestureEnabled -bool 'true'

# [12.5] Battery > Battery > Turn display off after = 10m
sudo pmset -b displaysleep 10

# [12.5] Battery > Power Adapter > Turn display off after = Never
sudo pmset -c displaysleep 0

# [12.5] Battery > Power Adapter > Prevent your Mac from automatically sleeping when the display is off = on
sudo pmset -c sleep 0

# [12.5] Sharing > Computer Name = ...
sudo scutil --set LocalHostName "$SET_HOSTNAME"
sudo scutil --set ComputerName "$SET_HOSTNAME"
dscacheutil -flushcache

# [12.5] Sharing > AirPlay Receiver = off
defaults -currentHost write com.apple.controlcenter AirplayRecieverEnabled -bool 'false'

# Apple ID > iCloud > Photos = off
# TODO Find Services[] element w/ Name = "PHOTO_STREAM"; set Enabled = 0
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > iCloud Drive = off
# TODO ... "MOBILE_DOCUMENTS" ... ; iCloudHomeShouldEnable = 0
# TODO defaults write MobileMeAccounts Accounts '(...)'
# PlistBuddy -c Set ':FK_StandardViewSettings:FXICloudDriveEnabled 0' "${HOME}/Library/Preferences/com.apple.finder.plist"
# PlistBuddy -c Set ':FK_StandardViewSettings:FXICloudDriveFirstSyncDownComplete 0' "${HOME}/Library/Preferences/com.apple.finder.plist"
# Apple ID > iCloud > Contacts = off
# TODO ... "CONTACTS" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Calendars = off
# TODO ... "CALENDAR" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Reminders = off
# TODO ... "REMINDERS" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Notes = off
# TODO ... "NOTES" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Safari = off
# TODO ... "BOOKMARKS" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > News = off
# TODO ... "NEWS" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Stocks = off
# TODO ... "STOCKS" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Home = off
# TODO ... "HOME" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Siri = off
# TODO ... "SIRI" ...
# TODO defaults write MobileMeAccounts Accounts '(...)'
defaults write com.apple.assistant.backedup 'Cloud Sync Enabled' -bool 'false'
defaults write com.apple.assistant.backedup 'Cloud Sync Enabled Modification Date' -date "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# UNDOCUMENTED > Disable "Tips" service
launchctl disable "gui/$(id -u)/com.apple.tipsd"

# UNDOCUMENTED > Expand save dialogs by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool 'true'

# UNDOCUMENTED > Expand print dialogs by default
defaults write -g PMPrintingExpandedStateForPrint2 -bool 'true'

# ====================
# Widgets
# ====================

# ====================
# Finder
# ====================

# [12.5] Preferences > General > Show these items on the desktop > Hard disks = on
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool 'true'

# [12.5] Preferences > General > Show these items on the desktop > Connected servers = on
defaults write com.apple.finder ShowMountedServersOnDesktop -bool 'true'

# [12.5] Preferences > General > New finder windows show = home directory
defaults write com.apple.finder NewWindowTarget -string 'PfHm'
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# [12.5] Preferences > Sidebar > Show these items in the sidebar > Favorites
mysides remove all
mysides add "$(logname)" "file://${HOME}/"
mysides add Applications file:///Applications/
mysides add Desktop file://${HOME}/Desktop/
mysides add Documents file://${HOME}/Documents/
mysides add Downloads file://${HOME}/Downloads/
mysides add Movies file://${HOME}/Movies/
mysides add Music file://${HOME}/Music/
mysides add Pictures file://${HOME}/Pictures/

# Preferences > Sidebar > Show these items in the sidebar > Favorites
# - AirDrop = on (sort at bottom of list)

# Preferences > Sidebar > Show these items in the sidebar > iCloud
# - iCloud Drive = off
# - Shared = off

# Preferences > Sidebar > Show these items in the sidebar > Locations
# - [All except computer] = on

# Grow sidebar to snap point

# [12.5] Preferences > Sidebar > Show these items in the sidebar > Tags > Recent Tags = off
defaults write com.apple.finder ShowRecentTags -bool 'false'

# [12.5] Preferences > Advanced > Show all filename extensions = on
defaults write -g AppleShowAllExtensions -bool 'true'

# [12.5] Preferences > Advanced > Keep folders on top > In windows when sorting by name = on
defaults write com.apple.finder _FXSortFoldersFirst -bool 'true'

# [12.5] Preferences > Advanced > When performing a search = Search the Current Folder
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'

# File > Get Info > Expand General, More Info, Name & Extension, Comments,
# Open with, Preview, Sharing & Permissions.
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
PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
#PlistBuddy -c 'Set :FK_DefaultIconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
PlistBuddy -c 'Set :FK_StandardViewSettings:IconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
PlistBuddy -c 'Set :StandardViewSettings:IconViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"
PlistBuddy -c 'Set :StandardViewSettings:GalleryViewSettings:arrangeBy name' "${HOME}/Library/Preferences/com.apple.finder.plist"

# UNDOCUMENTED > Delay before showing folder icon in window toolbars (sec)
defaults write -g NSToolbarTitleViewRolloverDelay -float 0.5

# UNDOCUMENTED > Disable warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool 'false'

# UNDOCUMENTED > Disable writing .DS_Store files on network shares
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool 'true'

# UNDOCUMENTED > Disable writing .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool 'true'

# UNDOCUMENTED > Delay before showing tooltips (ms)
defaults write -g NSInitialToolTipDelay -int 500

# ====================
# Dock
# ====================

<<COMMENT
defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

- chrome
- ff
- terminal
- sublime
- keepassxc
- vlc
- calc
- screenshot
- activity
**work**
- amazon chime
- docker
- zoom
COMMENT

# [12.5] Remove all apps and recents from Dock
defaults delete com.apple.dock.extra || true  # [12.5] doesn't exist on fresh install
defaults write com.apple.dock persistent-apps '()'
defaults write com.apple.dock persistent-others '()'
defaults write com.apple.dock recent-apps '()'

# ====================
# Calculator
# ====================

# [12.5] View > Scientific
defaults write com.apple.calculator ViewDefaultsKey -string 'Scientific'

# [12.5] View > Show Thousands Separators
defaults write com.apple.calculator SeparatorsDefaultsKey -bool 'true'

# ====================
# Font Book
# ====================

# [12.5] Preferences > Default Install Location = Computer
defaults write com.apple.FontBook FBDefaultInstallDomainRef -int '1'

# ====================
# Mission Control
# ====================

<<COMMENT
- Add Desktop
18754a18755,18760
>                             },
>                                                         {
>                                 ManagedSpaceID = 11;
>                                 id64 = 11;
>                                 type = 0;
>                                 uuid = "EB57FCD1-3FEC-44F9-A41E-93027C8806EA";
18781a18788
>                         24,
18784d18790
<                         24,
18787a18794,18800
>                 },
>                                 {
>                     name = "EB57FCD1-3FEC-44F9-A41E-93027C8806EA";
>                     windows =                     (
>                         28,
>                         342
>                     );
COMMENT

# ====================
# Disk Utility
# ====================

if [ "$CAPITALIZE_DISK" = true ]; then
    DISKNAME="$(tr '[:lower:]' '[:upper:]' <<< ${SET_HOSTNAME:0:1})${SET_HOSTNAME:1}"
else
    DISKNAME="$SET_HOSTNAME"
fi

# [12.5] Rename APFS disks to "[Hostname]" and "[Hostname] Data"
diskutil rename / "$DISKNAME"
diskutil rename /System/Volumes/Data "$DISKNAME Data"

# [12.5] View > Show All Devices
defaults write com.apple.DiskUtility SidebarShowAllDevices -bool 'true'

# [12.5] View > Show APFS Snapshots
defaults write com.apple.DiskUtility WorkspaceShowAPFSSnapshots -bool 'true'

# ====================
# Screenshot
# ====================

# Save screenshots to the clipboard
defaults write com.apple.screencapture target -string 'clipboard'

# ====================
# Terminal
# ====================

# Install "Basic Custom" profile
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

# Preferences > General > On startup, open new window with profile = [profile]
defaults write com.apple.Terminal 'Startup Window Settings' -string "$PROFILE_NAME"

# Preferences > Profiles > Set [profile] as Default
defaults write com.apple.Terminal 'Default Window Settings' -string "$PROFILE_NAME"

# View > Hide Marks
defaults write com.apple.Terminal ShowLineMarks -bool 'false'

# ====================
# Applications
# ====================

# Having Homebrew try to manage (extremely auto-updating) Firefox weirds me out
DMG=$(mktemp)
curl -fL 'https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US' -o "$DMG"
hdiutil attach "$DMG"
cp -rf /Volumes/Firefox/Firefox.app /Applications/Firefox.app
hdiutil detach /Volumes/Firefox

brew install keepassxc sublime-text vlc

dockutil --add '/Applications/Firefox.app'
dockutil --add '/System/Applications/Utilities/Terminal.app'
dockutil --add '/Applications/Sublime Text.app'
dockutil --add '/Applications/KeePassXC.app'
dockutil --add '/Applications/VLC.app'
dockutil --add '/Applications/Calculator.app'
dockutil --add '/System/Applications/Utilities/Screenshot.app'
dockutil --add '/System/Applications/Utilities/Activity Monitor.app'

# ====================
# Hope real hard that it all worked
# ====================

sudo shutdown -r now
