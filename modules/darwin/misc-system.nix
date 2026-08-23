# Per-user system plumbing: which account nix-darwin treats as primary, and the
# system's login-shell setup.
{ userConfig, ... }:

{
  # Records which nix-darwin generation's DEFAULTS this install was made
  # against; it is not a version to keep current. Read darwin-changes before
  # ever touching it — bumping it changes option defaults underneath you.
  system.stateVersion = 4;

  # Several nix-darwin options act on one specific user rather than the system:
  # `system.defaults` writes that user's plists, and Homebrew activation runs as
  # them. This names who.
  system.primaryUser = userConfig.username;

  users.users.${userConfig.username}.home = "/Users/${userConfig.username}";

  # System-side zsh only: /etc/zshrc, /etc/zprofile and listing zsh in
  # /etc/shells so it is a valid login shell. The user's own ~/.zshrc comes from
  # home-manager (modules/home-shared/programs/zsh.nix); these two do not
  # overlap.
  programs.zsh.enable = true;

  # No nix bash in the system profile. nixpkgs bash 5.3 feeds here-documents
  # through a pipe, and macOS pipes start at 512 bytes, so any heredoc larger
  # than that deadlocks (bash blocks in write() and never execs the command).
  # Dropping it leaves `bash`/`sh` on Apple's 3.2, which is unaffected; the nix
  # bash stays available per-project through a devShell / direnv.
  programs.bash.enable = false;
}
