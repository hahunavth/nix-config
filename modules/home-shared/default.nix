# Shared home-manager environment: the cross-platform "shared core" that runs on
# every host. Platform entry points import this and add their own extras:
#   modules/darwin/home -> this + default-browser + hammerspoon
#   modules/nixos/home  -> this (+ future Linux-only modules)
# User identity (username, homeDirectory, stateVersion) is set by the flake from
# the validated host entry.
{ ... }:

{
  imports = [
    # Per-host feature toggles (hn.* options)
    ./features.nix

    # Static dotfiles (home.file / xdg.configFile)
    ./files.nix

    # Categorized CLI packages
    ./packages/development.nix
    ./packages/system.nix

    # Programs & environment
    ./programs/git.nix
    ./programs/ssh.nix
    ./programs/zsh.nix
    ./programs/starship.nix
    ./programs/neovim.nix
    ./programs/tmux.nix
    ./programs/direnv.nix
    ./programs/fzf.nix
    ./programs/eza.nix
    ./programs/zoxide.nix
    ./programs/nh.nix
    ./programs/atuin.nix

    # Dev toolchains
    ./programs/mise.nix
    ./programs/maven.nix
    ./programs/atlassian-sdk.nix
    ./programs/atlassian-mise.nix
  ];
}
