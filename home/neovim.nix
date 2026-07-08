{ ... }:

{
  # neovimをデフォルトエディタにする（$EDITOR、vi/vimエイリアス）
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
