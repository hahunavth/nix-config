# nixos-desktop — host-specific home config (on top of the shared core).
# The GUI apps + CLI tools this VM needs (Claude Desktop / OpenCode Desktop are
# installed at system level in default.nix). "No lock screen" is handled there
# too (XFCE screensaver disabled).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vscode # unfree
    google-chrome # unfree
    vlc
    anydesk # remote desktop (unfree)
    claude-code
    opencode # AI coding agent (terminal/TUI)
    python314
    htop
  ];
}
