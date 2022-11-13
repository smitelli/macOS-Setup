// Preferences > General > Startup > Open previous windows and tabs = on
user_pref("browser.startup.page", 3);

// Preferences > General > Tabs > Confirm before quitting with Cmd + Q = off
user_pref("browser.warnOnQuitShortcut", false);

// Preferences > Home > New Windows and Tabs > Homepage and new windows = Blank Page
user_pref("browser.startup.homepage", "about:blank");

// Preferences > Home > New Windows and Tabs > New tabs = Blank Page
user_pref("browser.newtabpage.enabled", false);

// Preferences > Home > Firefox Home Content > Web Search = off
user_pref("browser.newtabpage.activity-stream.showSearch", false);

// Preferences > Home > Firefox Home Content > Shortcuts = off
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);

// Preferences > Home > Firefox Home Content > Recommended by Pocket = off
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);

// Preferences > Home > Firefox Home Content > Recent Activity = off
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);

// Preferences > Home > Firefox Home Content > Snippets = off
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);

// Preferences > Search > Search Suggestions > Show search suggestions in address bar results = off
user_pref("browser.urlbar.suggest.searches", false);

// Preferences > Privacy & Security > Browser Privacy > Enhanced Tracking Protection > Send websites a "Do Not Track" signal = Always
user_pref("privacy.donottrackheader.enabled", true);

// Preferences > Privacy & Security > Browser Privacy > Logins and Passwords > Ask to save logins and passwords for websites = off
user_pref("browser.formfill.enable", false);

// Preferences > Privacy & Security > Browser Privacy > Forms and Autofill > Autofill addresses = off
user_pref("extensions.formautofill.addresses.enabled", false);

// Preferences > Privacy & Security > Browser Privacy > Forms and Autofill > Autofill credit cards = off
user_pref("extensions.formautofill.creditCards.enabled", false);

// Preferences > Privacy & Security > Browser Privacy > History > Firefox will = Use custom settings for history
user_pref("privacy.history.custom", true);

// Preferences > Privacy & Security > Browser Privacy > History > Remember search and form history = off
user_pref("signon.rememberSignons", false);

// Preferences > Privacy & Security > Browser Privacy > Address Bar - Firefox Suggest > Bookmarks = off
user_pref("browser.urlbar.suggest.bookmark", false);

// Preferences > Privacy & Security > Browser Privacy > Address Bar - Firefox Suggest > Open tabs = off
user_pref("browser.urlbar.suggest.openpage", false);

// Preferences > Privacy & Security > Firefox Data Collection and Use > Allow Firefox to send tecnhical and interaction data = off
user_pref("datareporting.healthreport.uploadEnabled", false);

// Preferences > Privacy & Security > Firefox Data Collection and Use > Allow Firefox to install and run studies = off
user_pref("app.shield.optoutstudies.enabled", false);

// about:config > Warn me when I attempt to access these preferences = off
user_pref("browser.aboutConfig.showWarning", false);

// View > Toolbars > Bookmarks Toolbar > Never Show
user_pref("browser.toolbars.bookmarks.visibility", "never");

// View > Toolbars > Customize Toolbar...
user_pref("browser.uiCustomization.state", "{\"placements\":{\"widget-overflow-fixed-list\":[],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"urlbar-container\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\"],\"PersonalToolbar\":[]},\"seen\":[],\"dirtyAreaCache\":[],\"currentVersion\":18,\"newElementCount\":2}");

// UNDOCUMENTED > Hide the "List all tabs" button if there are not enough tabs open to warrant it
user_pref("browser.tabs.tabmanager.enabled", false);
