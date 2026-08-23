# System fonts. Just Nerd Fonts — the patched variants that carry the icon
# glyphs the prompt is built from.
#
# INSTALLING IS NOT SELECTING. A rebuild puts these in /Library/Fonts, but the
# terminal keeps whatever font it was configured with, so the prompt renders as
# replacement boxes until you pick "JetBrainsMono Nerd Font" (or FiraCode) in
# the terminal's own settings. That step cannot be done declaratively.
#
# The codepoints the prompt relies on are verified against
# nerd-fonts.jetbrains-mono specifically — see the glyph table in
# modules/home-shared/programs/starship.nix.
{ pkgs, ... }:

{
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
