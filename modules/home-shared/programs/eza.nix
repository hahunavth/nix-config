# eza — ls replacement. Its zsh integration takes over ls/ll/la/lt.
#
# Worth knowing that this shadows the real `ls`: eza's flags are not a superset
# of coreutils', so a script or a habit that passes an exotic flag needs
# `command ls` (interactive shells only, so scripts are unaffected).
{ ... }:

{
  programs.eza = {
    enable = true;
    git = true; # per-file git status column in long listings
    icons = "auto"; # only when stdout is a terminal, so pipes stay clean
  };
}
