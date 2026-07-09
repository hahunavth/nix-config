{ ... }:

{
  # Make neovim the default editor ($EDITOR, plus vi/vim aliases)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
