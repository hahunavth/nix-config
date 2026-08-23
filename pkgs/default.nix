# Every custom derivation in this repo, in one attrset.
#
# Wired into the flake TWICE — as `packages` (buildable by hand) and as
# `checks` (built by `nix flake check` and CI). That second wiring is the point:
# everything here is a fetchurl pin against someone else's server, so a moved
# tarball or rehashed release should fail in CI rather than halfway through a
# rebuild.
#
# This file is also the single source of the Atlassian SDK version pins —
# modules/home-shared/programs/atlassian-sdk.nix reads them from here rather
# than repeating the versions.
{ pkgs }:
let
  inherit (pkgs) lib;
  mkSdk = pkgs.callPackage ./atlassian-plugin-sdk { };
in
{
  # Both SDK generations stay installed side by side: which one a plugin repo
  # needs follows from its branch, not from the machine. Pair 8.2.7 with Java 8
  # and 9.1.1 with Java 17 (atlas-mise does this automatically).
  atlassian-plugin-sdk-8_2_7 = mkSdk {
    version = "8.2.7";
    url = "https://packages.atlassian.com/maven/public/com/atlassian/amps/atlassian-plugin-sdk/8.2.7/atlassian-plugin-sdk-8.2.7.tar.gz";
    hash = "sha256-d+t7pgSSEEJkLx06k7F/fk2tpXLKGuEtWiaWzu6WD3Y=";
  };
  atlassian-plugin-sdk-9_1_1 = mkSdk {
    version = "9.1.1";
    url = "https://packages.atlassian.com/mvn/maven-external/com/atlassian/amps/atlassian-plugin-sdk/9.1.1/atlassian-plugin-sdk-9.1.1.tar.gz";
    hash = "sha256-sEAe1eif9qXvIOu8RfZ4MWngEO5yCjU74g4Crd85J3Y=";
  };
}
# Electron apps repackaged from upstream .debs — for the nixos-desktop VM.
# Guarded on the system string so `nix flake check` on the Mac never tries to
# evaluate an amd64-Linux-only derivation.
// lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  claude-desktop = pkgs.callPackage ./claude-desktop { };
  opencode-desktop = pkgs.callPackage ./opencode-desktop { };
}
