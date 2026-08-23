# Layer 4 of 4 — the OrbStack dev VM's system config. Hostname `nixos`,
# headless aarch64 Linux.
#
# Nearly empty because this host barely owns anything: OrbStack generated its
# guest config (hostname, the kod_admin user, timezone, DNS, certs,
# stateVersion, and its own SSH), and that is imported verbatim from
# ../../modules/nixos/orbstack/ rather than restated here. The shared NixOS base
# is merged in by lib/mk-system.nix.
#
# Do not hand-edit anything under modules/nixos/orbstack/ — see its AGENTS.md.
# Cross-host settings go in modules/nixos/configuration.nix; anything specific
# to this VM and not OrbStack's belongs in this file.
{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    ../../modules/nixos/orbstack/configuration.nix
  ];
}
