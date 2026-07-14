# macOS home-manager entry: the shared cross-platform layer + macOS-only home
# modules. Wired as the darwin home entry point by lib/mk-system.nix.
{ ... }:

{
  imports = [
    ../../shared # cross-platform home (modules/shared)

    # macOS-only modules
    ./default-browser.nix # per-user LaunchServices default browser
    ./hammerspoon.nix # Lua automation (copy/paste sounds)
    ./conda.nix # miniconda shell init (macOS Homebrew cask)
    ./login-shell.nix # ~/.zprofile: Homebrew shellenv + OrbStack init
  ];
}
