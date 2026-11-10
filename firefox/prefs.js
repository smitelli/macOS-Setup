// [159.0] First run > Accept terms of use
user_pref("termsofuse.acceptedDate", "1794274845457");
user_pref("termsofuse.acceptedVersion", 4);

// [159.0] First run > Skip the welcome process
user_pref("browser.aboutwelcome.didSeeFinalScreen", true);

// [106.0] Preferences > General > Startup > Open previous windows and tabs = on
user_pref("browser.startup.page", 3);

// [106.0] Preferences > General > Tabs > Confirm before quitting with Cmd + Q = off
user_pref("browser.warnOnQuitShortcut", false);

// [144.0] Preferences > General > Browser Layout > Show sidebar = off
// [144.0] UNDOCUMENTED > Prefer old-style "bookmarks only" sidebar
user_pref("sidebar.old-sidebar.has-used", true);
user_pref("sidebar.revamp", false);

// [106.0] Preferences > Home > New Windows and Tabs > Homepage and new windows = Blank Page
user_pref("browser.startup.homepage", "chrome://browser/content/blanktab.html");

// [106.0] Preferences > Home > New Windows and Tabs > New tabs = Blank Page
user_pref("browser.newtabpage.enabled", false);

// [106.0] Preferences > Home > Firefox Home Content > Web Search = off
user_pref("browser.newtabpage.activity-stream.showSearch", false);

// [106.0] Preferences > Home > Firefox Home Content > Shortcuts = off
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);

// [106.0] Preferences > Home > Firefox Home Content > Recommended by Pocket = off
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);

// [106.0] Preferences > Home > Firefox Home Content > Recent Activity = off
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);

// [106.0] Preferences > Home > Firefox Home Content > Snippets = off
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);

// [106.0] Preferences > Search > Search Suggestions > Show search suggestions in address bar results = off
user_pref("browser.urlbar.suggest.searches", false);

// [106.0] Preferences > Privacy & Security > Browser Privacy > Logins and Passwords > Ask to save logins and passwords for websites = off
user_pref("browser.formfill.enable", false);

// [106.0] Preferences > Privacy & Security > Browser Privacy > Forms and Autofill > Autofill addresses = off
user_pref("extensions.formautofill.addresses.enabled", false);

// [106.0] Preferences > Privacy & Security > Browser Privacy > Forms and Autofill > Autofill credit cards = off
user_pref("extensions.formautofill.creditCards.enabled", false);

// [106.0] Preferences > Privacy & Security > Browser Privacy > History > Firefox will = Use custom settings for history
user_pref("privacy.history.custom", true);

// [106.0] Preferences > Privacy & Security > Browser Privacy > History > Remember search and form history = off
user_pref("signon.rememberSignons", false);

// [106.0] Preferences > Privacy & Security > Browser Privacy > Address Bar - Firefox Suggest > Bookmarks = off
user_pref("browser.urlbar.suggest.bookmark", false);

// [106.0] Preferences > Privacy & Security > Browser Privacy > Address Bar - Firefox Suggest > Open tabs = off
user_pref("browser.urlbar.suggest.openpage", false);

// [107.0] Preferences > Privacy & Security > Permissions > Location Settings... > Block new requests asking to access your location = on
user_pref("permissions.default.geo", 2);

// [106.0] Preferences > Privacy & Security > Firefox Data Collection and Use > Allow Firefox to send tecnhical and interaction data = off
user_pref("datareporting.healthreport.uploadEnabled", false);

// [106.0] Preferences > Privacy & Security > Firefox Data Collection and Use > Allow Firefox to install and run studies = off
user_pref("app.shield.optoutstudies.enabled", false);

// [159.0] Preferences > Dismiss "Password manager is disabled" security warning
user_pref("browser.preferences.config_warning.warningPasswordManager.dismissed", true);

// [106.0] about:config > Warn me when I attempt to access these preferences = off
user_pref("browser.aboutConfig.showWarning", false);

// [106.0] View > Toolbars > Bookmarks Toolbar > Never Show
user_pref("browser.toolbars.bookmarks.visibility", "never");

// [159.0] View > Toolbars > Customize Toolbar...
user_pref("browser.uiCustomization.state", "{\"currentVersion\":28,\"dirtyAreaCache\":[],\"placements\":{\"PersonalToolbar\":[],\"TabsToolbar\":[\"tabbrowser-tabs\",\"alltabs-button\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"urlbar-container\",\"jid1-mnnxcxisbpnsxq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"unified-extensions-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"unified-extensions-area\":[],\"vertical-tabs\":[],\"widget-overflow-fixed-list\":[]},\"seen\":[]}");
user_pref("browser.bookmarks.addedImportButton", true);

// [128.0] Preferences > Privacy & Security > Website Privacy Preferences > Tell websites not to sell or share my data = on
user_pref("privacy.globalprivacycontrol.enabled", true);

// [128.0] Preferences > Privacy & Security > Website Advertising Preferences > Allow websites to perform privacy-preserving ad measurement = off
user_pref("dom.private-attribution.submission.enabled", false);

// [129.0] Preferences > Search > Address Bar - Firefox Suggest > Search engines = off
user_pref("browser.urlbar.suggest.engines", false);

// [129.0] Preferences > Search > Address Bar - Firefox Suggest > Suggestions from Firefox = off
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);

// [129.0] Preferences > Search > Address Bar - Firefox Suggest > Suggestions from sponsors = off
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);

// [159.0] Preferences > Search > Firefox Suggest > Shortcuts = off
user_pref("browser.urlbar.suggest.topsites", false);

// [159.0] Preferences > Tabs and browsing > Recommendations > Recommend extensions as you browse = off
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);

// [159.0] Preferences > Tabs and browsing > Recommendations > Recommend features as you browse = off
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);

// [159.0] Preferences > AI controls > Block AI enhancements = on
user_pref("browser.ai.control.default", "blocked");

// [159.0] Right-click > Ask an AI Chatbot > Remove AI Chatbot
user_pref("browser.ml.chat.menu", false);

// [112.0] UNDOCUMENTED > Disable Pocket in all areas of the browser
user_pref("extensions.pocket.enabled", false);

// [106.0] UNDOCUMENTED > Hide the "List all tabs" button if there are not enough tabs open to warrant it
user_pref("browser.tabs.tabmanager.enabled", false);

// [108.0] UNDOCUMENTED > Skip the "Scam Warning" prompt when pasting into the Developer Tools Console
user_pref("devtools.selfxss.count", 5);

// [112.0] UNDOCUMENTED > Bring back the "Right-Click > View Image Info" menu option
user_pref("browser.menu.showViewImageInfo", true);

// [159.0] UNDOCUMENTED > Turn off nags to log into Firefox account and use sync services
user_pref("identity.fxaccounts.enabled", false);
