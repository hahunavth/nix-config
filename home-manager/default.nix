# Home Manager entry point: composes the user environment from modules/.
# User identity (username, homeDirectory, stateVersion) is set by the flake
# from the validated hosts.nix entry.
{ ... }:

{
  imports = [
    # Categorized CLI packages
    ./modules/packages/development.nix
    ./modules/packages/system.nix

    # Programs & environment
    ./modules/git.nix
    ./modules/ssh.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/neovim.nix
    ./modules/tmux.nix
    ./modules/direnv.nix
    ./modules/nh.nix
    ./modules/default-browser.nix
    ./modules/hammerspoon.nix

    # Dev toolchains
    ./modules/mise.nix
    ./modules/maven.nix
    ./modules/atlassian-sdk.nix
    ./modules/atlassian-mise.nix
  ];
}
