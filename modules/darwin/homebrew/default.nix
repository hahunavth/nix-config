# Wires nix-homebrew into nix-darwin and sets the SHARED base package lists.
#
# Base lists (taps.nix, brews/, casks/) apply to every macOS host. Host-specific
# casks/brews are owned by that host's own module in
# hosts/<name>/default.nix — `homebrew.casks` etc. are list options, so
# a host's entries merge with these.
#
# Note: the Atlassian Plugin SDK is NOT installed via Homebrew — its tap has
# broken formula class names and the atlas-* binaries collide on link; both SDK
# versions are pinned via pkgs/atlassian-plugin-sdk.
{ userConfig, ... }:
let
  taps = import ./taps.nix;
  brews = import ./brews/core.nix;
  casks =
    (import ./casks/apps.nix) ++ (import ./casks/development.nix) ++ (import ./casks/system.nix);
in
{
  # Manage the Homebrew installation itself declaratively
  nix-homebrew = {
    enable = true;
    user = userConfig.username;
    # Take over an existing /opt/homebrew installation
    autoMigrate = true;
    mutableTaps = true;
  };

  homebrew = {
    enable = true;
    inherit taps brews casks;

    onActivation = {
      # Keep rebuilds offline by default: no `brew update` fetch, no upgrading
      # already-installed casks/formulae just because a newer version exists
      # upstream. Run `brew-update` manually when you actually want that.
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap"; # removes casks/formulae not listed here on rebuild
      extraFlags = [ "--verbose" ]; # shows real per-cask progress
    };
  };
}
