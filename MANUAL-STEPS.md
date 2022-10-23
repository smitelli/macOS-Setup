# Manual Steps

## From-Scratch Installation

- Language = English
- Country or Region = United States
- Accessibility = Not Now
- Configure Wi-Fi network
- Migration Assistant = Not Now
- Agree to Terms and Conditions
- Create a Computer Account
    + Full name = Scott Smitelli
    + Account name = ssmitelli
    + Password = ...
    + Continue
- Enable Location Services on this Mac = on
- Analytics
    + Share Mac Analytics with Apple = off
    + Share crash and usage data with app developers = off
- Screen Time = Set Up Later
- Enable Ask Siri = off
- Touch ID = Set Up Touch ID Later
- Choose Your Look = Dark

## Post-Bootstrap Settings

- System Preferences
    + Touch ID
        * Add TODO
    + Keyboard
        * Text
            - Remove that stupid "omw" replacement

- Notifications & Focus
-- Focus (gets odd when Apple ID is set up)

- Internet Accounts
-- (Apple ID accounts)

- Security & Privacy
-- Advanced
--- Require an administrator password
-- General
--- Require password ... = immediately
-- Privacy
--- Location Services
---- System Services > Details...
----- Allow [Find My Mac] to determine your location = on

- Software Update
-- Advanced...
--- Download new ... = off
--- Install system data files ... = off

- Network
-- Delete Thunderbolt Bridge

- Sound
-- Sound Effects
--- Play sound on startup = off

- Touch ID
-- Add at least 2 index fingers
-- Enable for [all]

- Apple ID
-- iCloud
--- Allow Find My Mac

contacts card
dictation is different depending on touch bar presence

# Apple ID > iCloud > Photos = off
# Find Services[] element w/ Name = "PHOTO_STREAM"; set Enabled = 0
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > iCloud Drive = off
# ... "MOBILE_DOCUMENTS" ... ; iCloudHomeShouldEnable = 0
# defaults write MobileMeAccounts Accounts '(...)'
# PlistBuddy -c Set ':FK_StandardViewSettings:FXICloudDriveEnabled 0' "${HOME}/Library/Preferences/com.apple.finder.plist"
# PlistBuddy -c Set ':FK_StandardViewSettings:FXICloudDriveFirstSyncDownComplete 0' "${HOME}/Library/Preferences/com.apple.finder.plist"
# Apple ID > iCloud > Contacts = off
# ... "CONTACTS" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Calendars = off
# ... "CALENDAR" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Reminders = off
# ... "REMINDERS" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Notes = off
# ... "NOTES" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Safari = off
# ... "BOOKMARKS" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > News = off
# ... "NEWS" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Stocks = off
# ... "STOCKS" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Home = off
# ... "HOME" ...
# defaults write MobileMeAccounts Accounts '(...)'
# Apple ID > iCloud > Siri = off
# ... "SIRI" ...
# defaults write MobileMeAccounts Accounts '(...)'
defaults write com.apple.assistant.backedup 'Cloud Sync Enabled' -bool 'false'
defaults write com.apple.assistant.backedup 'Cloud Sync Enabled Modification Date' -date "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# Preferences > Sidebar > Show these items in the sidebar > Favorites
# - AirDrop = on (sort at bottom of list)

# Preferences > Sidebar > Show these items in the sidebar > iCloud
# - iCloud Drive = off
# - Shared = off

# Preferences > Sidebar > Show these items in the sidebar > Locations
# - [All except computer] = on

# Grow sidebar to snap point


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

## Default Stuff

```bash
defaults read > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(defaults read)
defaults -currentHost read > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(defaults -currentHost read)
find /Library/Preferences -type f -exec defaults read '{}' \; > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(find /Library/Preferences -type f -exec defaults read '{}' \;)
F=$(mktemp); cp ~/Library/Preferences/com.apple.Terminal.plist "$F"; plutil -convert xml1 "$F"; less -S "$F"
````
