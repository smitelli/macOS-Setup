# Manual Steps

## From-Scratch Installation (12.6)

- Language = **English**
- Select Your Country or Region = **United States**
- Accessibility = Not Now
- Select Your Wi-Fi Network = ...
- Migration Assistant = Not Now
- Sign In with Your Apple ID = Set Up Later; Skip
- Terms and Conditions = Agree; Agree
- Create a Computer Account
    + Full name = **Scott Smitelli**
    + Account name = **ssmitelli**
    + Password = ...
- Enable Location Services on this Mac = **on**
- Analytics
    + Share Mac Analytics with Apple = **off**
    + Share crash and usage data with app developers = **off**
- Screen Time = Set Up Later
- Enable Ask Siri = **off**
- Touch ID = Set Up Touch ID Later; Continue
- Choose Your Look = Dark

Once at the desktop, open Terminal.app and follow instructions from the README.

## Post-Bootstrap Settings (12.6)

- System Preferences
    + **Sign In** to Apple ID
        * Allow Find My Mac to use the location of this Mac? = **Allow**
    + Apple ID
        * iCloud > Enable all except:
            - **Private Relay**
            - **Hide My Email**
            - **iCloud Mail**
            - **Contacts**
            - **Calendars**
            - **Notes**
            - (If work computer, disable _everything_ except **Find My Mac**)
        * Media & Purchases > Account: ... > Manage... > **Log into the App Store**
    + Internet Accounts > Add **Gmail**:
        * Details... > Description = email address
        * Enable (at a minimum) **Contacts**
    + Users & Groups > Current User > Contacts Card: > **Open...**
        * Make sure Contacts.app is set up with the correct account
        * Card > Make This My Card
        * Remove any incorrect entries that refer to the current user
    + Security & Privacy > General > Require password ... after sleep or screen saver begins = **immediately**
    + Software Update > Advanced... > Install system data files and security updates = **off**
    + Network > Thunderbolt Bridge > **Remove** (if not being used)
    + Touch ID > Add fingerprints:
        1. **RH Index**
        2. **LH Index**
        3. **RH thumb**
    + Keyboard > Text > Remove the **omw** replacement if present
- Finder Preferences > Sidebar
    + AirDrop = **on**
    + iCloud Drive = **off**
    + Hard disks = **on**

--- TODO ---

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

# Preferences > Sidebar > Show these items in the sidebar > iCloud
# - iCloud Drive = off
# - Shared = off

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
