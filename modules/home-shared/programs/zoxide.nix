# zoxide — `z <fragment>` jumps to the best-matching directory you have already
# visited (frecency-ranked), `zi` picks from the matches interactively via fzf.
#
# Owns the `z` command exclusively: the oh-my-zsh `z` plugin is left out of the
# list in ./zsh.nix for this reason, since with both loaded the winner is
# whichever sourced last.
#
# The database is runtime state (~/.local/share/zoxide), not managed here — a
# fresh machine starts with no history and learns as you cd.
{ ... }:

{
  programs.zoxide.enable = true;
}
