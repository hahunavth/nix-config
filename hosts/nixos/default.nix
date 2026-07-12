# OrbStack dev VM — hostname `nixos` (headless aarch64 Linux). This host owns its
# system config: it pulls in the OrbStack-generated guest integration. Shared
# NixOS base (../../modules/nixos) is added by lib/mk-system.nix. The hostname,
# user, timezone and stateVersion come from the OrbStack files.
{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    ../../modules/nixos/orbstack/configuration.nix
  ];
}
