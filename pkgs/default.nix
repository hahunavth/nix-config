# Aggregated custom packages, exported by the flake's `packages` output and
# built by `checks` (so `nix flake check` catches a rotted URL/hash). Also the
# single source of the Atlassian SDK version pins (consumed by
# home-manager/modules/atlassian-sdk.nix).
{ pkgs }:
let
  inherit (pkgs) lib;
  mkSdk = pkgs.callPackage ./atlassian-plugin-sdk { };
in
{
  # Pinned Atlassian Plugin SDKs. Pair 8.2.7 with Java 8, 9.1.1 with Java 17.
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
# Raycast Beta is a macOS-only arm64 DMG; only expose it on Darwin.
// lib.optionalAttrs pkgs.stdenv.isDarwin {
  raycast-beta = import ./raycast-beta {
    inherit pkgs;
    inherit (pkgs) lib;
  };
}
# Repackaged amd64 Linux .deb GUI apps (x86_64-linux only).
// lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  claude-desktop = pkgs.callPackage ./claude-desktop { };
  opencode-desktop = pkgs.callPackage ./opencode-desktop { };
}
