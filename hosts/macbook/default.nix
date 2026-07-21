# Work Mac — hostname KOD-ADMINs-MacBook-Pro. This host owns its machine-specific
# system config. Shared macOS config (../../modules/darwin) and the cross-platform
# home core are added by lib/mk-system.nix; host-specific home is in ./home.nix.
{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking = {
    hostName = "KOD-ADMINs-MacBook-Pro";
    computerName = "KOD-ADMINs-MacBook-Pro";
    localHostName = "KOD-ADMINs-MacBook-Pro";
  };

  # Corporate apps unique to this machine; merge with the shared cask base in
  # modules/darwin/homebrew/ (homebrew.casks is a list option).
  homebrew.casks = [
    "anydesk" # remote desktop
    "microsoft-office" # Word, Excel, PowerPoint, OneNote
    "microsoft-teams"
    "remote-desktop-manager"
    "slack"
    "teamviewer"
    "zoom"
  ];

  # Mac App Store apps (installed via the `mas` CLI, which brew auto-installs when
  # this list is non-empty). NOTE: `mas` can only INSTALL apps already obtained on
  # the signed-in Apple ID — it can't "Get"/buy a new one. So the first time, open
  # the App Store and click Get on Service Station once; rebuilds keep it after.
  # Service Station adds a configurable TOP-LEVEL Finder right-click menu (free; a
  # one-off IAP unlocks unlimited entries). Enable its Finder extension after
  # install: System Settings → General → Login Items & Extensions → Finder extensions.
  homebrew.masApps = {
    "Service Station" = 1503136033;
  };

  nix.linux-builder.enable = false;
}
