{ pkgs, ... }:

let
  # raycast beta
  raycastBetaDmg = import ./raycast-beta.nix { inherit pkgs; lib = pkgs.lib; };

in
{
  # raycast beta
  system.activationScripts.postActivation.text = ''
    if [ ! -e "/Applications/Raycast Beta.app" ]; then
      echo "Installing Raycast Beta..."
      MOUNT_POINT=$(mktemp -d)
      hdiutil attach "${raycastBetaDmg}" -nobrowse -mountpoint "$MOUNT_POINT"
      cp -R "$MOUNT_POINT/Raycast Beta.app" /Applications/
      hdiutil detach "$MOUNT_POINT"
      rmdir "$MOUNT_POINT"
      chmod -R u+w "/Applications/Raycast Beta.app"
    fi
  '';

  ids.gids.nixbld = 350;

  # システムにインストールするパッケージ
  environment.systemPackages = with pkgs; [
    vim
    git
    neovim
    starship
  ];

  # nix-darwin now manages nix-daemon automatically when nix.enable is on
  nix.package = pkgs.nix;

  # zshの設定
  programs.zsh.enable = true;

  # 非自由パッケージを許可
  nixpkgs.config.allowUnfree = true;

  # Finder設定
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    CreateDesktop = false;
    FXEnableExtensionChangeWarning = false;
    ShowPathbar = true;
    ShowStatusBar = true;
  };

  # Dock設定
  system.defaults.dock = {
    autohide = true;
    show-recents = false;
    tilesize = 50;
    magnification = true;
    largesize = 64;
    orientation = "bottom";
    mineffect = "scale";
    launchanim = false;
  };

  # 下位互換性のため（変更時はchangelogを確認）
  system.stateVersion = 4;

  # ターゲットプラットフォーム
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Homebrew integration (for GUI apps not well-suited to nixpkgs)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";   # removes casks/formulae not listed here on rebuild
      extraFlags = [ "--verbose" ];   # <-- shows real per-cask progress
    };


    casks = [
      "claude"                 # Claude desktop app
      "slack"
      "arc"
      "google-chrome"
      "microsoft-edge"
      "visual-studio-code"
      "microsoft-office"       # Word, Excel, PowerPoint, OneNote
      "microsoft-teams"
      "remote-desktop-manager"
    ];
  };

}

