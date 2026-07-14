# Shell aliases, split by domain (merged into programs.zsh.shellAliases by
# modules/zsh.nix). Add new alias groups as files here.
{
  lib,
  pkgs,
  winTunnel ? true,
}:
let
  coreAliases = import ./core.nix { inherit pkgs; };
  winTunnelAliases = if winTunnel then import ./win-tunnel.nix { inherit lib; } else { };
in
coreAliases // winTunnelAliases
