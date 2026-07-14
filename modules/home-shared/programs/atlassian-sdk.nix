{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Version pins live in pkgs/ (single source; also built by `nix flake check`).
  # Pinned via nix rather than Homebrew (its tap is broken: bad formula class
  # names + colliding atlas-* symlinks). Pair 8.2.7 with Java 8, 9.1.1 with Java 17.
  customPkgs = import ../../../pkgs { inherit pkgs; };
in
lib.mkIf config.hn.atlassian.enable {
  # Stable paths so project .mise.toml files can add the right SDK to PATH
  # without referencing a volatile /nix/store path.
  home.file.".local/share/atlassian-plugin-sdk/8.2.7".source = customPkgs.atlassian-plugin-sdk-8_2_7;
  home.file.".local/share/atlassian-plugin-sdk/9.1.1".source = customPkgs.atlassian-plugin-sdk-9_1_1;
}
