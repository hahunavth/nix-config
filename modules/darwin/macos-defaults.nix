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
  # Finder. Mostly about seeing what is actually there — extensions, hidden
  # files, the real POSIX path — rather than the curated view Finder ships with.
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

  # Dock. Kept visible and non-animated: autohide trades a sliver of screen for
  # a delay on every reach, and launchanim delays the thing you just clicked.
  system.defaults.dock = {
    autohide = false;
    show-recents = true;
    tilesize = 36;
    magnification = true;
    largesize = 64;
    orientation = "bottom";
    mineffect = "genie";
    launchanim = false;
    # Spaces stay in the order you put them in. With this on, macOS reorders by
    # recent use and a Space's position — the thing muscle memory targets —
    # changes under you.
    mru-spaces = false;
  };

  # Click the wallpaper to reveal the desktop. Sonoma made this Stage-Manager-only
  # by default, which makes it feel broken the rest of the time; this is the
  # "Always" setting.
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = true;

  # Menu bar / Control Center. Most of these have no typed nix-darwin option and
  # would need CustomUserPreferences; only the ones that do are set.
  system.defaults.controlcenter = {
    BatteryShowPercentage = true;
    # Bluetooth = true;               # show Bluetooth in menu bar
    # Sound = true;                   # show Sound in menu bar
  };

  # No .DS_Store on network shares or USB/external volumes. Worth it beyond
  # tidiness: those files travel to other people's machines and into archives,
  # and on the external SSD they are pure noise. Local disks still get them —
  # Finder needs somewhere to keep per-folder view state.
  #
  # No typed option exists, so this goes through CustomUserPreferences, which
  # writes the domain's plist keys directly.
  system.defaults.CustomUserPreferences."com.apple.desktopservices" = {
    DSDontWriteNetworkStores = true;
    DSDontWriteUSBStores = true;
  };

  # Drop the "downloaded from the internet, are you sure?" prompt. This is the
  # first-open nag, NOT Gatekeeper signature checking, which still applies. Note
  # modules/darwin/homebrew/default.nix explains why the cask-side equivalent of
  # this must not be set.
  system.defaults.LaunchServices.LSQuarantine = false;
  # system.defaults.loginwindow.GuestEnabled = false;
  # system.startup.chime = false;                          # mute boot chime
}
