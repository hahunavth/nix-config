{ ... }:

{
  # home-managerでzshを管理する（~/.zshrcが生成される）
  # これによりstarship / mise / neovim等のzsh統合が有効になる
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
