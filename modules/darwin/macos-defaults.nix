# macOS user defaults (the `defaults write` surface, declared).
#
# TIMING: a rebuild writes the plist, but a RUNNING process only rereads it at
# login. Dock/Finder/WindowManager and input-source changes therefore need a
# logout or restart before they show up — a switch that "did nothing" is
# usually this, not a broken option.
#
# NEVER declare `AppleEnabledInputSources` via CustomUserPreferences: it
# replaces the whole list and would wipe the manually configured ABC +
# Vietnamese (Telex) + Japanese (Kotoeri) input methods.
#
# No typed nix-darwin option for a setting? Use
# `system.defaults.CustomUserPreferences."<domain>"` (see the .DS_Store block).
{ ... }:

{
  # Finder settings
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    CreateDesktop = true;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
    ShowStatusBar = true;
    FXDefaultSearchScope = "SCcf"; # search current folder, not whole Mac
    _FXSortFoldersFirst = true;
    FXPreferredViewStyle = "Nlsv"; # list view by default
    _FXShowPosixPathInTitle = true; # full path in window title
    QuitMenuItem = true; # allow ⌘Q to quit Finder
  };

  # Dock settings
  system.defaults.dock = {
    autohide = false;
    show-recents = true;
    tilesize = 36;
    magnification = true;
    largesize = 64;
    orientation = "bottom";
    mineffect = "genie";
    launchanim = false;
    mru-spaces = false; # stop auto-reordering Spaces
  };

  # Click wallpaper to reveal desktop ("Always", not only in Stage Manager)
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = true;

  # Control Center / menu bar
  system.defaults.controlcenter = {
    BatteryShowPercentage = true;
    # Bluetooth = true;               # show Bluetooth in menu bar
    # Sound = true;                   # show Sound in menu bar
  };

  # Stop .DS_Store litter on network/USB — via CustomUserPreferences
  system.defaults.CustomUserPreferences."com.apple.desktopservices" = {
    DSDontWriteNetworkStores = true;
    DSDontWriteUSBStores = true;
  };

  system.defaults.LaunchServices.LSQuarantine = false; # no "are you sure you want to open?" on downloads
  # system.defaults.loginwindow.GuestEnabled = false;
  # system.startup.chime = false;                          # mute boot chime
}
