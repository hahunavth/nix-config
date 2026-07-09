# Core system aliases (platform-aware: darwin-rebuild vs nixos-rebuild).
{ pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # Rebuild the system from the flake (works from any directory). On the
  # OrbStack VM the repo is reached via the Mac's virtiofs mount at
  # /private/etc/nix-darwin; nixos-rebuild picks the config by hostname.
  rebuild =
    if isDarwin then
      "sudo darwin-rebuild switch --flake /etc/nix-darwin"
    else
      "sudo nixos-rebuild switch --flake /private/etc/nix-darwin";
  # Same, via nh: unprivileged build + a diff of what changed (uses NH_FLAKE)
  rebuild2 = if isDarwin then "nh darwin switch" else "nh os switch";
}
