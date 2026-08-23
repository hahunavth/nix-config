{ userConfig, ... }:

{
  # For backwards compatibility (check the changelog before changing)
  system.stateVersion = 4;

  # Some nix-darwin options (user defaults, Homebrew, ...) apply to this user
  system.primaryUser = userConfig.username;

  users.users.${userConfig.username}.home = "/Users/${userConfig.username}";

  # zsh system-wide (login shell integration; home-manager manages ~/.zshrc)
  programs.zsh.enable = true;

  # No nix bash in the system profile. nixpkgs bash 5.3 feeds here-documents
  # through a pipe, and macOS pipes start at 512 bytes, so any heredoc larger
  # than that deadlocks (bash blocks in write() and never execs the command).
  # Dropping it leaves `bash`/`sh` on Apple's 3.2, which is unaffected; the nix
  # bash stays available per-project through a devShell / direnv.
  programs.bash.enable = false;
}
