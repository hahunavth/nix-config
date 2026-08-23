# Shell aliases, split by domain (merged into programs.zsh.shellAliases by
# modules/zsh.nix). Add new alias groups as files here.
{
  lib,
  pkgs,
  homelabTunnel ? true,
}:
let
  coreAliases = import ./core.nix { inherit pkgs; };
  homelabTunnelAliases = if homelabTunnel then import ./homelab-tunnel.nix { inherit lib; } else { };
in
coreAliases // homelabTunnelAliases
