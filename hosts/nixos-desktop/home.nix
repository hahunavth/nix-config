# Layer 4 of 4 — the XFCE VM's home config: the apps this machine wants, on top
# of the shared core.
#
# GUI apps come from nixpkgs here, not Homebrew — the casks-for-GUI rule is a
# macOS rule, and on Linux nixpkgs is the better source.
#
# Two exceptions live in ./default.nix instead, at system level: Claude Desktop
# and OpenCode Desktop, because they are built from this flake's own `packages`
# and `self` is only in the system specialArgs.
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
