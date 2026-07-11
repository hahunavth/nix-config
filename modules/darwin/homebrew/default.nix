# Wires nix-homebrew into nix-darwin and composes common Homebrew packages
# with profile-specific overrides.
#
# Shared package lists live beside this file (taps.nix, brews/, casks/). Profile
# overrides live in ./profiles/. Edit those, not this file.
#
# Note: the Atlassian Plugin SDK is NOT installed via Homebrew — its tap has
# broken formula class names and the atlas-* binaries collide on link; both SDK
# versions are pinned via pkgs/atlassian-plugin-sdk.
{ userConfig, ... }:
let
  homebrewLib = import ./lib.nix;
  profileName = userConfig.profile or "personal";
  common = import ./profiles/common.nix;
  profile = import (./profiles + "/${profileName}.nix");
  taps = homebrewLib.composeList common.taps profile.extraTaps profile.removeTaps;
  brews = homebrewLib.composeList common.brews profile.extraBrews profile.removeBrews;
  casks = homebrewLib.composeList common.casks profile.extraCasks profile.removeCasks;
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
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # removes casks/formulae not listed here on rebuild
      extraFlags = [ "--verbose" ]; # shows real per-cask progress
    };

    # Mac App Store apps
    masApps = common.masApps // profile.masApps;
  };
}
