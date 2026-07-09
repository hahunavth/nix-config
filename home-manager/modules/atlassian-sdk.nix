{ pkgs, ... }:

let
  mkSdk = pkgs.callPackage ../../pkgs/atlassian-plugin-sdk { };

  # Pinned via nix rather than Homebrew (its tap is broken: bad formula class
  # names + colliding atlas-* symlinks). Pair 8.2.7 with Java 8, 9.1.1 with Java 17.
  sdk827 = mkSdk {
    version = "8.2.7";
    url = "https://packages.atlassian.com/maven/public/com/atlassian/amps/atlassian-plugin-sdk/8.2.7/atlassian-plugin-sdk-8.2.7.tar.gz";
    hash = "sha256-d+t7pgSSEEJkLx06k7F/fk2tpXLKGuEtWiaWzu6WD3Y=";
  };
  sdk911 = mkSdk {
    version = "9.1.1";
    url = "https://packages.atlassian.com/mvn/maven-external/com/atlassian/amps/atlassian-plugin-sdk/9.1.1/atlassian-plugin-sdk-9.1.1.tar.gz";
    hash = "sha256-sEAe1eif9qXvIOu8RfZ4MWngEO5yCjU74g4Crd85J3Y=";
  };
in
{
  # Stable paths so project .mise.toml files can add the right SDK to PATH
  # without referencing a volatile /nix/store path.
  home.file.".local/share/atlassian-plugin-sdk/8.2.7".source = sdk827;
  home.file.".local/share/atlassian-plugin-sdk/9.1.1".source = sdk911;
}
