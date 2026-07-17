# eza — modern ls. The zsh integration aliases ls/ll/la/lt to eza.
{ ... }:

{
  programs.eza = {
    enable = true;
    git = true; # git status column in long listings
    icons = "auto";
  };
}
