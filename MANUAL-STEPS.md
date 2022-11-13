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
- Mission Control > Create two desktops on each display
- Notification Center > Edit Widgets
    + Calendar > Month
    + (same row) Clock > World Clock (S)
        * New York, U.S.A.
        * Los Angeles, U.S.A.
        * UTC
    + Weather > Forecast (L)
        * Location: My Location
- Finder
    + Preferences > Sidebar
        * AirDrop = **on**
        * iCloud Drive = **off**
        * Shared = **off**
        * Hard disks = **on**
    + If computer/user name(s) are long, expand sidebar to first snap point
- Firefox
    + Open Firefox at least once to initialize and fill the profile directory
    + `bash -c "$(curl -fsSL https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD/firefox/setup.sh)"`
    + Follow the output of the script to finish installing add-ons

## Default Stuff

```bash
defaults read > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(defaults read)
defaults -currentHost read > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(defaults -currentHost read)
find /Library/Preferences -type f -exec defaults read '{}' \; > /tmp/defaults; read -sp $'?\n' -n1; diff /tmp/defaults <(find /Library/Preferences -type f -exec defaults read '{}' \;)
F=$(mktemp); cp ~/Library/Preferences/com.apple.Terminal.plist "$F"; plutil -convert xml1 "$F"; less -S "$F"
````
