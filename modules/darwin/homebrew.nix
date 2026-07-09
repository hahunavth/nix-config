{ profile, lib, ... }:

let
  inherit (import ../../lib { inherit lib; }) composeList;

  # base package sets + the active profile's add/remove overrides
  common = (import ../../profiles/common.nix).homebrew;
  prof = (import (../../profiles + "/${profile}.nix")).homebrew;
in
{
  # Homebrew integration (for GUI apps not well-suited to nixpkgs).
  # Package lists are composed from profiles/ (common + <profile>); edit those,
  # not this file. Note: the Atlassian Plugin SDK is NOT installed via Homebrew —
  # its tap has broken formula class names and the atlas-* binaries collide on
  # link; both SDK versions are pinned via pkgs/atlassian-plugin-sdk.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # removes casks/formulae not listed here on rebuild
      extraFlags = [ "--verbose" ]; # shows real per-cask progress
    };

    taps = composeList (common.taps or [ ]) (prof.extraTaps or [ ]) (prof.removeTaps or [ ]);
    brews = composeList (common.brews or [ ]) (prof.extraBrews or [ ]) (prof.removeBrews or [ ]);
    casks = composeList (common.casks or [ ]) (prof.extraCasks or [ ]) (prof.removeCasks or [ ]);
    masApps = (common.masApps or { }) // (prof.masApps or { });
  };
}
