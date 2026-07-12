# Feature registry: hn.* toggles for optional user modules.
#
# Each host opts in from its own hosts/<name>/home.nix, e.g.:
#   hn.atlassian.enable = true;
# Defaults are platform-based where sensible (hammerspoon/defaultBrowser are
# macOS-only); everything else is off. Consuming modules use
# `lib.mkIf config.hn.<feature>.enable`.
{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  isDarwin = pkgs.stdenv.isDarwin;

  # Defaults: platform-based where it makes sense, else off (host opts in).
  defaults = {
    atlassian = false;
    hammerspoon = isDarwin;
    defaultBrowser = isDarwin;
    winTunnel = false;
    secrets = false;
    atuin = false;
  };

  mkFeature =
    name: description:
    mkOption {
      inherit description;
      type = types.bool;
      default = defaults.${name};
    };
in
{
  options.hn = {
    atlassian.enable = mkFeature "atlassian" "Atlassian Plugin SDK + branch-based mise/Java switching (work tooling).";
    hammerspoon.enable = mkFeature "hammerspoon" "Hammerspoon copy/paste sounds (macOS only).";
    defaultBrowser.enable = mkFeature "defaultBrowser" "Set Arc as the default browser on activation (macOS only).";
    winTunnel.enable = mkFeature "winTunnel" "socat port-forward aliases to the Windows box (work).";
    secrets.enable = mkFeature "secrets" "sops-nix age-encrypted secrets (requires an age key on the machine).";
    atuin.enable = mkFeature "atuin" "Atuin shell-history (Ctrl-R search + optional cross-machine sync).";
  };
}
