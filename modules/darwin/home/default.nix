# macOS home-manager entry: the shared cross-platform layer + macOS-only home
# modules. Wired as the darwin home entry point by lib/mk-system.nix.
{ ... }:

{
  imports = [
    ../../home-shared # cross-platform home (modules/home-shared)

    # macOS-only modules
    ./default-browser.nix # per-user LaunchServices default browser
    ./hammerspoon.nix # Lua automation (copy/paste sounds)
    ./service-station-reload.nix # reload Service Station's Finder ext on volume remount (hn.serviceStationReload)
    ./conda.nix # miniconda shell init (macOS Homebrew cask)
    ./login-shell.nix # ~/.zprofile: Homebrew shellenv + OrbStack init
  ];
}
