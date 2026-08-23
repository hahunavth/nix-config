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
    homelabTunnel = false;
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
    homelabTunnel.enable = mkFeature "homelabTunnel" "socat port-forward aliases to the homelab over Tailscale (work).";
    secrets.enable = mkFeature "secrets" "sops-nix age-encrypted secrets (requires an age key on the machine).";
    atuin.enable = mkFeature "atuin" "Atuin shell-history (Ctrl-R search + optional cross-machine sync).";

    # Per-user LaunchServices default handler for http/https (macOS only).
    # Consumed by modules/darwin/home/default-browser.nix.
    defaultBrowser = {
      enable = mkFeature "defaultBrowser" "Set the default browser on activation (macOS only).";
      handler = mkOption {
        type = types.str;
        default = "browser";
        example = "hammerspoon";
        description = ''
          Handler to pass to defaultbrowser(1) — the short name it prints, not a
          bundle id. Arc's is "browser" (bundle company.thebrowser.Browser). Run
          `defaultbrowser` with no arguments to list the registered handlers.
        '';
      };
      app = mkOption {
        type = types.str;
        default = "/Applications/Arc.app";
        description = "Guard: the handler is only set if this app bundle exists, so a fresh machine doesn't get a broken default.";
      };
    };

    # Hammerspoon: Lua automation for event-driven macOS behaviour (macOS only).
    # Consumed by modules/darwin/home/hammerspoon.nix.
    hammerspoon = {
      enable = mkFeature "hammerspoon" "Hammerspoon Lua automation (macOS only).";

      autoLaunch = mkOption {
        type = types.bool;
        default = true;
        description = "Start Hammerspoon at login (hs.autoLaunch). Effectively required once it handles URLs or watches volumes.";
      };

      autoReload = mkOption {
        type = types.bool;
        default = true;
        description = "Reload Hammerspoon when ~/.hammerspoon/*.lua changes — without it, a rebuild's new config only takes effect on a manual reload.";
      };

      clipboardSounds.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Play a short blip on Cmd+C / Cmd+V (needs Accessibility permission).";
      };

      # React to external volumes mounting/unmounting. The other half of the
      # same replug is hn.staleCwdRecovery, which repairs each shell's cwd --
      # only the shell itself can do that, so the two are not interchangeable.
      volumeWatch = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Watch the volumes below and react when they mount or unmount (macOS only).";
        };
        volumes = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [ "/Volumes/ext_ssd" ];
          description = "Mount-point paths to react to; any other volume event is ignored.";
        };
        notify = mkOption {
          type = types.bool;
          default = true;
          description = "Show an on-screen alert when a watched volume mounts or ejects.";
        };
        onMount = mkOption {
          type = types.lines;
          default = "";
          example = "/usr/bin/pluginkit -e use -i com.knurling.ServiceStation.FinderSync";
          description = "Shell run via /bin/sh -c when a watched volume mounts. Runs async; a non-zero exit is logged to the Hammerspoon console.";
        };
        onUnmount = mkOption {
          type = types.lines;
          default = "";
          description = "Shell run via /bin/sh -c when a watched volume unmounts.";
        };
      };

      # Make Hammerspoon the system http/https handler and dispatch links to a
      # real browser by hostname. Sets hn.defaultBrowser.handler by default.
      urlRouter = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Route opened links to a browser chosen by hostname (macOS only).";
        };
        fallback = mkOption {
          type = types.str;
          default = "company.thebrowser.Browser";
          description = "Bundle id of the browser for anything no rule matches. Also restored as the system handler when Hammerspoon quits.";
        };
        rules = mkOption {
          type = types.listOf (
            types.submodule {
              options = {
                hosts = mkOption {
                  type = types.listOf types.str;
                  example = [ "^localhost$" ];
                  description = "Lua patterns matched against the lowercased hostname (no scheme, no port).";
                };
                bundleId = mkOption {
                  type = types.str;
                  example = "com.google.Chrome";
                  description = "Bundle id of the browser to open a matching URL in.";
                };
              };
            }
          );
          default = [ ];
          description = "Host-pattern → browser rules, matched in order; the first match wins, otherwise `fallback`.";
        };
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
          Export DOCKER_CONTEXT=<name>. Home-manager puts session variables in
          ~/.zshenv, so this reaches non-interactive zsh (scripts) too, not just
          prompts. Still yields to `docker --context` and to a per-project
          DOCKER_HOST, but it does shadow `docker context use` (which then reports
          success and changes nothing) — use the `dctx` function to switch a shell
          instead. null leaves the choice to `docker context use`.
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
