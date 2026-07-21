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

    # Reload the Service Station Finder Sync extension when a watched external
    # volume (re)mounts (macOS only). Consumed by
    # modules/darwin/home/service-station-reload.nix.
    serviceStationReload = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Reload Service Station's Finder extension when a watched volume remounts (macOS only).";
      };
      volumes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "/Volumes/ext_ssd" ];
        description = "Mount-point paths to watch; on (re)mount the Finder extension is reloaded so its menu re-binds.";
      };
      extensionId = mkOption {
        type = types.str;
        default = "com.knurling.ServiceStation.FinderSync";
        description = "Bundle identifier of the Finder Sync extension to reload via pluginkit.";
      };
      restartFinder = mkOption {
        type = types.bool;
        default = true;
        description = "Also relaunch Finder after reloading the extension (restores windows; aborts any in-progress Finder copy).";
      };
    };
  };
}
