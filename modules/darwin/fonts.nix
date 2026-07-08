{ pkgs, ... }:

{
  # Nerd Font (needed for starship prompt glyphs)
  # Select "JetBrainsMono Nerd Font" in your terminal's font settings
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
