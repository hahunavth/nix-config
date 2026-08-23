# Layer 4 of 4 — the work Mac's own SYSTEM config. Hostname
# KOD-ADMINs-MacBook-Pro, Apple Silicon.
#
# Only what is true of this machine and no other belongs here. The shared macOS
# platform layer (../../modules/darwin) is merged alongside by lib/mk-system.nix,
# so this file is short by design — if something here would be right on a second
# Mac, it belongs in that layer instead.
#
# The user-facing half of this host is ./home.nix.
{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  networking = {
    hostName = "KOD-ADMINs-MacBook-Pro";
    computerName = "KOD-ADMINs-MacBook-Pro";
    localHostName = "KOD-ADMINs-MacBook-Pro";
  };

  # Work-only apps: real on this machine, noise on a personal one. `homebrew.casks`
  # is a list option, so these MERGE with the shared base in
  # modules/darwin/homebrew/casks/ rather than replacing it.
  #
  # Remember cleanup = "zap": deleting a line uninstalls the app.
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

  # No Linux remote builder on this machine. Evaluating the NixOS hosts from
  # here only needs --dry-run, and their real switches run inside the VMs — so
  # the background VM this would keep running has nothing to do. Overrides the
  # mkDefault in modules/darwin/linux-builder.nix.
  nix.linux-builder.enable = false;
}
