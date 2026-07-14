# Login-shell environment for macOS — brought under home-manager instead of the
# untracked ~/.zprofile that the Homebrew and OrbStack installers write to.
# `profileExtra` becomes the generated ~/.zprofile (sourced by login shells).
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
