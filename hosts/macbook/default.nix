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

  nix.linux-builder.enable = false;
}
