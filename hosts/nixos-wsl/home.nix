# Layer 4 of 4 — the WSL distro's home config, on top of the shared core.
#
# Meant to feel like the Mac: same shell/git/editor from home-shared, the
# Atlassian tooling on, and mise owning the runtimes. One difference: the Mac
# gets Python from the miniconda cask, which has no counterpart here, so mise
# owns Python on this host too.
#
# Off on purpose: hn.homelabTunnel (this machine IS the homelab), hn.remoteDocker
# (Docker runs locally — hosts/nixos-wsl/default.nix), hn.secrets.
{ pkgs, ... }:

{
  hn.atlassian.enable = true; # Atlassian Plugin SDK + branch-based mise switching
  hn.atuin.enable = true; # Ctrl-R history search (sync dormant until `atuin login`)

  # Merged into the shared globals (node lts, pnpm, bun, java 25/17/8).
  programs.mise.globalConfig.tools = {
    python = "3.13";
    # Expo / EAS cloud builds + submits. `npx expo` itself needs no global.
    "npm:eas-cli" = "latest";
  };
  # Use the prebuilt python-build-standalone tarball (runs via nix-ld) instead
  # of compiling with pyenv's python-build, which fails on NixOS without the
  # headers in FHS paths.
  programs.mise.globalConfig.settings.python.compile = false;

  home.packages = with pkgs; [
    claude-code # unfree

    # git extras
    git-lfs
    lazygit
    delta

    # general CLI
    htop
    wget
    tree
    unzip
    zip

    # React Native / Expo: Metro uses watchman for file watching when present.
    # The Android SDK + JDK 17 come per project from `nix develop .#mobile`
    # (shells/mobile.nix), loaded by direnv: `use flake ~/nix-config#mobile`.
    watchman
  ];
}
