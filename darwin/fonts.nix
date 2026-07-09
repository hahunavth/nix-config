{ pkgs, ... }:

{
  # Nerd Fonts (needed for starship prompt glyphs)
  # Select one of these in your terminal's font settings, e.g.
  # "JetBrainsMono Nerd Font" or "FiraCode Nerd Font"
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
