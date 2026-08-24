# Alias aggregator — merged into programs.zsh.shellAliases by programs/zsh.nix.
#
# Plain functions taking { lib, pkgs, ... }, not nix modules, because these are
# imported and merged as an attrset rather than evaluated by the module system.
# The consequence worth knowing: an hn.* toggle cannot be read from `config`
# here, so a gated alias group is passed in as an argument (see homelabTunnel)
# and zsh.nix is what reads the flag.
#
# Add a group: drop <domain>.nix beside this file and merge it below.
{
  lib,
  pkgs,
  homelabTunnel ? true,
}:
let
  coreAliases = import ./core.nix { inherit pkgs; };
  claudeAliases = import ./claude.nix { };
  homelabTunnelAliases = if homelabTunnel then import ./homelab-tunnel.nix { inherit lib; } else { };
in
coreAliases // claudeAliases // homelabTunnelAliases
