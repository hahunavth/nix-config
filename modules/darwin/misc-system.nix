{ userConfig, ... }:

{
  # For backwards compatibility (check the changelog before changing)
  system.stateVersion = 4;

  # Some nix-darwin options (user defaults, Homebrew, ...) apply to this user
  system.primaryUser = userConfig.username;

  users.users.${userConfig.username}.home = "/Users/${userConfig.username}";

  # zsh system-wide (login shell integration; home-manager manages ~/.zshrc)
  programs.zsh.enable = true;
}
