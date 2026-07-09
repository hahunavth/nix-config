# Shell aliases, split by domain (merged into programs.zsh.shellAliases by
# modules/zsh.nix). Add new alias groups as files here.
{ lib, ... }:
let
  coreAliases = import ./core.nix;
  winTunnelAliases = import ./win-tunnel.nix { inherit lib; };
in
coreAliases // winTunnelAliases
