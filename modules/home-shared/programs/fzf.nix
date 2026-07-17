# fzf — fuzzy finder wired into zsh: Ctrl-R fuzzy history search, Ctrl-T
# insert a file path into the current command, Alt-C cd into a subdirectory.
# Uses fd for file listing so results respect .gitignore.
{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git";
    fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git"; # Ctrl-T
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d --hidden --exclude .git"; # Alt-C
  };
}
