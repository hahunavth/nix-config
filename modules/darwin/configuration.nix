{ pkgs, ... }:

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

  # Machine identity (hostName/computerName/localHostName) is owned by the host:
  # see hosts/<name>/default.nix.
}
