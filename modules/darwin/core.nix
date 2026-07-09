{ pkgs, ... }:

{
  ids.gids.nixbld = 350;

  # System-wide packages
  # (neovim / starship are managed on the home-manager side, under home/)
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # nix-darwin now manages nix-daemon automatically when nix.enable is on
  nix.package = pkgs.nix;

  # Enable flakes etc. by default (no more --extra-experimental-features)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection (every Sunday 4:00, delete generations older than 30 days)
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 4; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  # Deduplicate the nix store
  nix.optimise.automatic = true;

  # zsh
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # For backwards compatibility (check the changelog before changing)
  system.stateVersion = 4;
}
