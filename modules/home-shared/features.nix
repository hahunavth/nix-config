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

    # Docker CLI talking to a remote engine over SSH (no local daemon).
    # Consumed by modules/home-shared/programs/docker.nix.
    remoteDocker = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Install the Docker CLI (no engine) and declare remote-engine contexts.";
      };
      contexts = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          homelab = "ssh://homelab-tailscale";
        };
        description = ''
          Docker contexts to declare: context name -> DOCKER_HOST URL. The ssh://
          form needs a matching Host block in programs/ssh.nix and `docker` on the
          remote PATH. Each name also gets a `dk-<name>` alias.
        '';
      };
      defaultContext = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "homelab";
        description = ''
          Export DOCKER_CONTEXT=<name> in every shell. null (default) leaves the
          choice to `docker context use`, which is per-machine state but stays
          overridable per command and per project.
        '';
      };
    };

    # Re-enter the working directory when a watched external volume is unplugged
    # and replugged, so the shell stops erroring on every command (macOS only).
    # Consumed by modules/darwin/home/stale-cwd.nix.
    staleCwdRecovery = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Recover the shell's working directory after a watched volume remounts (macOS only).";
      };
      volumes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "/Volumes/ext_ssd" ];
        description = "Mount-point paths to guard; the recovery hook is inert unless the cwd is on one of them.";
      };
      waitTimeout = mkOption {
        type = types.ints.unsigned;
        default = 0;
        example = 300;
        description = "Seconds to hold the prompt waiting for the volume; 0 waits indefinitely. Ctrl-C always ends the wait.";
      };
    };
  };
}
