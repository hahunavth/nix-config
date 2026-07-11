# Feature registry: per-host toggles for optional user modules.
#
# Each `hn.<feature>.enable` defaults from the host's `features` set
# (hosts/<host>.nix), falling back to a sensible per-profile / per-platform
# default. A host turns a feature on/off with e.g.:
#
#   features = { hammerspoon = false; atlassian = true; };
#
# Modules consume these via `lib.mkIf config.hn.<feature>.enable`. Declaring the
# options here (once) keeps consuming modules free of duplicate declarations.
{
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  inherit (lib) mkOption types;
  features = userConfig.features or { };
  isWork = (userConfig.profile or "personal") == "work";
  isDarwin = pkgs.stdenv.isDarwin;

  # Per-feature default (host `features` value wins; else profile/platform rule).
  defaults = {
    atlassian = features.atlassian or isWork;
    hammerspoon = features.hammerspoon or isDarwin;
    defaultBrowser = features.defaultBrowser or isDarwin;
    winTunnel = features.winTunnel or isWork;
    # Opt-in: requires an age key on the machine (see docs/runbooks/secrets.md).
    secrets = features.secrets or false;
    # Opt-in: changes Ctrl-R history search; enable once >1 host to sync across.
    atuin = features.atuin or false;
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
