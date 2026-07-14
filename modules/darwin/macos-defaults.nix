{ ... }:

{
  # Finder settings
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    CreateDesktop = false;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
    ShowStatusBar = true;
    FXDefaultSearchScope = "SCcf";      # search current folder, not whole Mac
    _FXSortFoldersFirst = true;
    FXPreferredViewStyle = "Nlsv";      # list view by default
    _FXShowPosixPathInTitle = true;     # full path in window title
    QuitMenuItem = true;                # allow ⌘Q to quit Finder
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
    mru-spaces = false;                # stop auto-reordering Spaces
  };

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

  system.defaults.LaunchServices.LSQuarantine = false;   # no "are you sure you want to open?" on downloads
  # system.defaults.loginwindow.GuestEnabled = false;
  # system.startup.chime = false;                          # mute boot chime

}
