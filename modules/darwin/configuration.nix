# The leftovers: settings with no better home than "macOS, all hosts".
#
# Anything with a theme of its own gets its own file in this directory. When a
# group here grows past a couple of entries, that is the signal to split it out.
{ pkgs, ... }:

{
  # Must match the GID the nix installer actually created for the build group,
  # or activation fails on the mismatch. 350 is what this machine has.
  ids.gids.nixbld = 350;

  # Unfree is opted into wholesale rather than per package: several things this
  # config depends on (the Claude apps, vscode, teamviewer) are unfree, and
  # per-package allowlists silently break on a rename.
  nixpkgs.config.allowUnfree = true;

  # Deliberately almost empty. Tools belong to the user (home-manager), and the
  # only reason to put one here is to have it before/without a user profile —
  # which is exactly the case for a rescue editor and git during recovery.
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Machine identity (hostName / computerName / localHostName) is NOT here — it
  # is the one thing a host must own, since the flake selects a configuration by
  # hostname. See hosts/<name>/default.nix.
}
