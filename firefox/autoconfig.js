// Enable cfg file https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
// Without this line, cfg file will miss access to browser objects like Components or Services?
// Messing with the order of these makes ffx crash
pref("general.config.sandbox_enabled", false);
// Name of the cfg file
pref("general.config.filename", "firefox.nico.cfg");
// config file shouldn't be obfuscated
pref("general.config.obscure_value", 0);
