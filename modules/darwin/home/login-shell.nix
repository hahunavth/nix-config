# ~/.zprofile for macOS — reclaimed from the Homebrew and OrbStack installers,
# both of which append to it and leave it untracked.
#
# `profileExtra` generates ~/.zprofile, which LOGIN shells source. That is the
# right file for these two: PATH belongs in a login shell so every child process
# inherits it, whereas ~/.zshrc (programs/zsh.nix) runs per interactive shell and
# would redo the work on every prompt while still missing non-interactive ones.
# Session variables that must reach scripts go in ~/.zshenv instead
# (home.sessionVariables).
#
# Both lines are macOS-only, which is why this lives in the darwin home layer
# rather than the cross-platform shared zsh module (Homebrew/OrbStack are not
# present on the NixOS hosts):
#   - brew shellenv: puts /opt/homebrew on PATH and exports HOMEBREW_* for login
#     shells.
#   - OrbStack init: command-line tools + docker/kubectl/orb integration; the
#     sourced file guards its own existence, so it's a no-op if absent.
{ ... }:

{
  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"

    # Added by OrbStack: command-line tools and integration
    source ~/.orbstack/shell/init.zsh 2>/dev/null || :
  '';
}
