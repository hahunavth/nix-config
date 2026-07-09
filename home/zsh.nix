{ ... }:

{
  # Manage zsh with home-manager (generates ~/.zshrc)
  # This is what enables the zsh integrations for starship / mise / neovim etc.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Rebuild the system from the flake (works from any directory)
      rebuild = "sudo darwin-rebuild switch --flake /etc/nix-darwin";
    };
  };
}
