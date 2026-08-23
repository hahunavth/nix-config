# Homebrew, made declarative — both the installation itself (via nix-homebrew)
# and the package lists.
#
# Why Homebrew at all, in a nix config: macOS GUI apps. Casks deliver a real
# signed .app into /Applications where Spotlight, Launch Services and the app's
# own updater expect it. nixpkgs GUI apps on darwin are second-class by
# comparison, so the rule is casks for GUI, nix for CLI.
#
# Scope: the lists imported below (taps.nix, brews/, casks/) apply to EVERY
# macOS host. A cask only one machine wants belongs to that machine —
# `homebrew.casks` in hosts/<name>/default.nix, which merges with these because
# they are list options.
#
# Not here: the Atlassian Plugin SDK. Its tap is broken (mismatched formula
# class names, and the atlas-* binaries collide on link so two versions cannot
# coexist), so both versions come from pkgs/atlassian-plugin-sdk instead.
{ userConfig, ... }:
let
  taps = import ./taps.nix;
  brews = import ./brews/core.nix;
  casks =
    (import ./casks/apps.nix) ++ (import ./casks/development.nix) ++ (import ./casks/system.nix);
in
{
  # Own /opt/homebrew itself, not just what is installed into it — otherwise
  # brew is an unmanaged prerequisite that a fresh machine has to set up by hand
  # before this config can work.
  nix-homebrew = {
    enable = true;
    user = userConfig.username;
    # Adopt an existing hand-installed Homebrew rather than refusing to start.
    # Needed on any machine that had brew before nix.
    autoMigrate = true;
    # Taps stay writable, so `brew tap` still works ad hoc. Locking them down
    # would break any formula that pulls in a tap on demand.
    mutableTaps = true;
  };

  homebrew = {
    enable = true;
    inherit taps brews casks;

    # NOTE: do NOT set `caskArgs.no_quarantine` here. `brew bundle` renders
    # caskArgs keys verbatim (`no_quarantine` -> `--no_quarantine`, an option
    # brew never had), and Homebrew 6 dropped `--no-quarantine` from
    # `brew install` altogether: cmd/install.rb never passes `quarantine:` to
    # Cask::Installer, whose default is hardcoded `quarantine: true`.
    # `HOMEBREW_CASK_OPTS="--no-quarantine"` is ignored for the same reason
    # (EnvConfig.cask_opts_quarantine? has no callers left). Setting it doesn't
    # just fail silently — it makes every NEW cask install abort with
    # "Error: invalid option: --no_quarantine".
    # If a Gatekeeper "could not verify <app>" prompt shows up again, fix the
    # route to Apple's notarization service (a half-dead VPN daemon caused it
    # last time) or clear the attribute per app:
    #   xattr -dr com.apple.quarantine "/Applications/<App>.app"

    onActivation = {
      # Rebuilds stay OFFLINE and non-upgrading. A switch should change exactly
      # what this repo changed — not whatever Homebrew found upstream that
      # morning — and it should not stall on a metadata fetch when the network
      # is slow. `brew-update` (aliases/core.nix) is the deliberate opt-in.
      autoUpdate = false;
      upgrade = false;
      # The declaration is the whole truth: anything installed through Homebrew
      # but not listed here (or in a host module) is UNINSTALLED on the next
      # rebuild. So adding a line is the install and deleting it is the
      # uninstall — and an app added by hand will not survive.
      cleanup = "zap";
      # Cask installs are slow and silent otherwise, which reads as a hung
      # rebuild.
      extraFlags = [ "--verbose" ];
    };
  };
}
