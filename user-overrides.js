//user_pref("browser.urlbar.autoFill", false);
//user_pref("browser.urlbar.suggest.addons", false);

//user_pref("browser.urlbar.suggest.mdn", false);
//
//
//user_pref("browser.urlbar.suggest.recentsearches", false);
//
//user_pref("signon.rememberSignons", false);
//user_pref("signon.management.page.breach-alerts.enabled", false);
//user_pref("signon.generation.enabled", false);
//user_pref("signon.firefoxRelay.feature", "disabled");

//  Permissions, Privacy and Cookies
user_pref("media.eme.enabled", false);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.microphone", 2);
user_pref("cookiebanners.service.mode", 1);
user_pref("cookiebanners.service.mode.privateBrowsing", 1);
user_pref("cookiebanners.service.enableGlobalRules", true);

// CleanUI
user_pref("extensions.pocket.enabled", false); 
user_pref("browser.tabs.tabmanager.enabled", false); 
user_pref("identity.fxaccounts.enabled", false); 
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.translations.automaticallyPopup", false);

//  Smoothfox
user_pref("general.autoScroll", true);
user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("mousewheel.min_line_scroll_amount", 10); // 10-40; adjust this number to your liking; default=5
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 80); // default=50
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15"); // default=.25
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); // default=.4

user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
user_pref("general.smoothScroll", true); // DEFAULT
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", 2.0);
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("general.smoothScroll.currentVelocityWeighting", 1.0);
user_pref("general.smoothScroll.stopDecelerationWeighting", 1.0);
user_pref("mousewheel.default.delta_multiplier_y", 400); // 250-400; adjust this number to your liking
