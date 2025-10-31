# Manual Steps

## From-Scratch Installation (15.7)

- Language = **English**
- Select Your Country or Region = **United States**
- Transfer Your Data to This Mac = **Set up as new**
- Accessibility = Not Now
- Select Your Wi-Fi Network = ...
- Create a Computer Account
    + Full name = **Scott Smitelli**
    + Account name = **ssmitelli**
    + Password = ...
    + Allow computer account password to be reset ... = **off**
- Sign In with Your Apple ID = Set Up Later; Skip
- Terms and Conditions = Agree; Agree
- Enable Location Services on this Mac = **on**
- Analytics
    + Share Mac Analytics with Apple = **off**
    + Share crash and usage data with app developers = **off**
- Screen Time = Set Up Later
- Apple Intelligence = Set Up Later
- Enable Ask Siri = **off**
- Touch ID = Set Up Touch ID Later; Continue
- Choose Your Look = Dark
- Update Mac Automatically = Only Download Automatically

Once at the desktop, open Terminal.app and follow instructions from the README.

## Post-Bootstrap Settings (14.0)

- System Settings
    + **Sign In** to Apple ID
        * Allow Find My Mac to use the location of this Mac? = **Allow**
    + Apple ID
        * iCloud > Enable all except:
            - **iCloud Mail**
            - **Notes**
            - **Contacts**
            - **Calendars**
            - **Private Relay**
            - (If work computer, disable _everything_ except **Find My Mac**)
        * iCloud > Optimize Mac Storage = off
    + Internet Accounts > Add **Gmail**:
        * Details... > Description = email address
        * Enable (at a minimum) **Contacts**
    + Users & Groups > Current User > Contacts Card: > **Open...**
        * Make sure Contacts.app is set up with the correct account
        * Card > Make This My Card
        * Remove any incorrect entries that refer to the current user
    + Lock Screen > Require password after screen saver begins or display is turned off = **immediately**
    + General > Software Update > Advanced... > Install Security Responses and system files = **off**
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
    + Settings > Sidebar
        * AirDrop = **on**
        * iCloud Drive = **off**
        * Shared = **off**
        * Hard disks = **on**
    + If computer/user name(s) are long, expand sidebar to first snap point
- Firefox
    + Open Firefox at least once to initialize and fill the profile directory
    + `bash -c "$(curl -fsSL https://raw.githubusercontent.com/smitelli/macOS-Setup/HEAD/firefox/setup.sh)"`
    + Follow the output of the script to finish installing add-ons
- Sublime Text 4
    + Open Sublime Text 4 at least once to initialize and fill the profile directory
    + `~/.scottfiles/st4/setup.sh`

## Property List Reading/Dumping Stuff

```bash
dump_defaults() {
    echo '=== SUDO Any Host ==='
    sudo defaults read
    echo '=== SUDO Current Host ==='
    sudo defaults -currentHost read
    echo '=== SUDO Local Host ==='
    sudo defaults -host localhost read
    echo '=== Any Host ==='
    defaults read
    echo '=== Current Host ==='
    defaults -currentHost read
    echo '=== Local Host ==='
    defaults -host localhost read
}
dump_defaults > /tmp/before; read -sp $'?\n' -n1; dump_defaults > /tmp/after; diff /tmp/{before,after}
# for zsh, use read -sk $'??'

dump_defaults_dumb() {
    sudo find /Library/Preferences -type f -exec echo {} \; -exec plutil -p {} \;
    find ~/Library/Preferences -type f -exec echo {} \; -exec plutil -p {} \;
}
dump_defaults_dumb > /tmp/before; read -sp $'?\n' -n1; dump_defaults_dumb > /tmp/after; diff /tmp/{before,after}

dump_plist_xml() {
    F=$(mktemp); cp "$1" "$F"; plutil -convert xml1 "$F"; cat "$F"
}
````
