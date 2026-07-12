# nixos-desktop — host-specific home config (on top of the shared core).
# The GUI apps + CLI tools this VM needs (Claude Desktop is installed at system
# level in default.nix). "no lock screen" is set via GNOME dconf below.
{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    vscode # unfree
    google-chrome # unfree
    vlc
    claude-code
    python314
    htop
  ];

  # No lock screen: disable the GNOME screensaver lock and idle blanking.
  dconf.settings = {
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
      idle-activation-enabled = false;
    };
    "org/gnome/desktop/session".idle-delay = lib.gvariant.mkUint32 0; # never blank
  };
}
