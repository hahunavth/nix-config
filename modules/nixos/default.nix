# Shared NixOS base imported by every Linux host. Per-host system bundles
# (hardware + desktop, or the OrbStack guest config) live in hosts/<hostname>/
# and are added alongside this by lib/mk-system.nix.
{
  imports = [
    ./configuration.nix
  ];
}
