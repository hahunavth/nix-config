# Layer 1 of 4 — the macOS platform base. System scope, so everything here
# needs sudo and touches the machine (/etc, LaunchDaemons, Homebrew, macOS
# defaults) rather than the user's home.
#
# Applied to EVERY macOS host by lib/mk-system.nix, so nothing here may assume
# a particular machine. Per-machine system config belongs in
# hosts/<name>/default.nix, which is merged alongside this — list options like
# homebrew.casks combine, and a scalar marked lib.mkDefault here can simply be
# assigned over there.
#
# The user-facing half of a macOS host is ./home/, wired in separately.
{
  imports = [
    ./configuration.nix
    ./nix-settings.nix
    ./misc-system.nix
    ./security.nix
    ./linux-builder.nix
    ./fonts.nix
    ./macos-defaults.nix
    ./homebrew
  ];
}
