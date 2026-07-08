{ lib, username, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./ssh.nix
    ./zsh.nix
    ./starship.nix
    ./neovim.nix
    ./mise.nix
  ];

  # ユーザー情報
  home.username = username;
  # lib.mkForceを使用しているのは、nix-darwinの既知のバグ（Issue #682）に対処するためです。
  # https://github.com/LnL7/nix-darwin/issues/682
  # このバグが修正されたら、単に "/Users/${username}" と設定できるようになる可能性があります。
  home.homeDirectory = lib.mkForce "/Users/${username}";

  # home-managerのバージョン（変更時は注意）
  home.stateVersion = "26.05";

  # home-managerの有効化
  programs.home-manager.enable = true;
}
