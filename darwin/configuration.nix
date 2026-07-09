{ pkgs, userConfig, ... }:

{
  ids.gids.nixbld = 350;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  # (neovim / starship / CLI tools are managed on the home-manager side)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Machine identity comes from the hosts.nix registry
  networking = {
    hostName = userConfig.hostname;
    computerName = userConfig.hostname;
    localHostName = userConfig.hostname;
  };
}
