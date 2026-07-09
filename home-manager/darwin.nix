# macOS home-manager entry point: shared modules + darwin-only extras.
{ ... }:

{
  imports = [
    ./default.nix

    # macOS-only modules
    ./modules/default-browser.nix # per-user LaunchServices default browser
    ./modules/hammerspoon.nix # Lua automation (copy/paste sounds)
  ];
}
