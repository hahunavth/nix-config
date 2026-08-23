# Layer 3 of 4 — the macOS home layer. Home scope: runs as the user, generates
# files under ~, no sudo.
#
# Two jobs: pull in the cross-platform core, then add the modules that could
# only ever work on macOS. The test for belonging here rather than in
# home-shared is whether the module would break or be meaningless on Linux —
# LaunchServices, Hammerspoon, Homebrew paths, /Volumes all qualify.
#
# lib/mk-system.nix imports this as the darwin home entry point, alongside
# hosts/<name>/home.nix.
{ ... }:

{
  imports = [
    ../../home-shared # layer 2: everything that is not platform-bound

    # macOS-only. Several of these are inert unless the matching hn.* toggle is
    # set by the host (see modules/home-shared/features.nix).
    ./default-browser.nix # per-user LaunchServices default browser
    ./hammerspoon.nix # Lua automation: URL routing, volume watch, clipboard sounds
    ./stale-cwd.nix # re-enter the cwd after a volume remount (hn.staleCwdRecovery)
    ./conda.nix # miniconda shell init (macOS Homebrew cask)
    ./login-shell.nix # ~/.zprofile: Homebrew shellenv + OrbStack init
  ];
}
