# neovim as the system editor.
#
# Config-free on purpose: this only makes nvim present and default. Editor
# configuration stays in the user's own ~/.config/nvim, outside nix, because a
# store-managed read-only config fights every plugin manager.
#
# defaultEditor sets $EDITOR, which is what git, `crontab -e` and friends read.
# viAlias/vimAlias mean muscle memory (`vi`, `vim`) lands here too — including
# on macOS, where they would otherwise reach Apple's vim.
{ ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
