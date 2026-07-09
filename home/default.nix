{ lib, username, ... }:

{
  imports = [
    ./packages.nix
    ./default-browser.nix
    ./git.nix
    ./ssh.nix
    ./zsh.nix
    ./starship.nix
    ./neovim.nix
    ./mise.nix
    ./atlassian-sdk.nix
    ./atlassian-mise.nix
  ];

  # User info
  home.username = username;
  # lib.mkForce works around a known nix-darwin bug (Issue #682).
  # https://github.com/LnL7/nix-darwin/issues/682
  # Once that bug is fixed, this may be settable as plain "/Users/${username}".
  home.homeDirectory = lib.mkForce "/Users/${username}";

  # home-manager version (be careful when changing)
  home.stateVersion = "26.05";

  # Enable home-manager
  programs.home-manager.enable = true;
}
