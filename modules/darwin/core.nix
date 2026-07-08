{ pkgs, ... }:

{
  ids.gids.nixbld = 350;

  # システムにインストールするパッケージ
  # neovim / starship はhome-manager側（home/）で管理する
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # nix-darwin now manages nix-daemon automatically when nix.enable is on
  nix.package = pkgs.nix;

  # flakes等を標準で有効化（--extra-experimental-features不要になる）
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ガベージコレクション（毎週日曜2:00、30日より古い世代を削除）
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 2; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  # nixストアの重複排除
  nix.optimise.automatic = true;

  # zshの設定
  programs.zsh.enable = true;

  # 非自由パッケージを許可
  nixpkgs.config.allowUnfree = true;

  # 下位互換性のため（変更時はchangelogを確認）
  system.stateVersion = 4;
}
