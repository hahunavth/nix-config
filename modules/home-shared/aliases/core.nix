# Aliases every host gets. Platform-aware, so the same word does the right
# thing on the Mac and inside the Linux VMs.
{ pkgs, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # Rebuild from the flake, from any directory — the path is absolute on
  # purpose so this works when cwd is somewhere else entirely.
  #
  # The two paths are the same checkout: the OrbStack VM sees the Mac's
  # /etc/nix-darwin through a virtiofs mount at /private/etc/nix-darwin. Neither
  # command names a host — both rebuild tools select the configuration by the
  # machine's own hostname.
  rebuild =
    if isDarwin then
      "sudo darwin-rebuild switch --flake /etc/nix-darwin"
    else
      "sudo nixos-rebuild switch --flake /private/etc/nix-darwin";
  # Same switch through nh, which builds unprivileged first and prints a diff of
  # what the generation changes. No --flake needed: programs/nh.nix sets
  # NH_FLAKE.
  rebuild2 = if isDarwin then "nh darwin switch" else "nh os switch";
}
// (
  # Homebrew's half of a rebuild is deliberately offline (autoUpdate and upgrade
  # are both false in modules/darwin/homebrew/default.nix), so a switch never
  # silently upgrades an app or stalls on a metadata fetch. This is the manual
  # opt-in for when you do want that. --greedy also upgrades casks that
  # auto-update themselves, which brew otherwise leaves alone.
  if isDarwin then { brew-update = "brew update && brew upgrade --greedy"; } else { }
)
