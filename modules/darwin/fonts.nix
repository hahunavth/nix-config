{ pkgs, ... }:

{
  # Nerd Font（starshipプロンプトの記号表示に必要）
  # ターミナルのフォント設定で "JetBrainsMono Nerd Font" を選択すること
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
