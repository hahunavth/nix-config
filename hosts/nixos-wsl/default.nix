# nixos-wsl — x86_64 NixOS under WSL2 on the Windows work PC. This host owns its
# system config: the WSL integration, the login user, the local Docker engine.
# The shared NixOS base (../../modules/nixos) is added by lib/mk-system.nix.
#
# No bootloader and no hardware-configuration.nix: WSL boots the distro itself,
# and the NixOS-WSL module (flake input `nixos-wsl`) supplies everything a
# generated hardware config would.
#
# The distro's disk lives at D:\WSL\NixOS (moved off C: with
# `wsl --manage NixOS --move`). Windows drives are mounted under /mnt/<letter>.
{
  pkgs,
  self,
  userConfig,
  ...
}:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    self.inputs.nixos-wsl.nixosModules.default
  ];

  wsl.enable = true;
  # The NixOS-WSL tarball installs as user `nixos`; switch to the global
  # identity so home-manager lands in /home/<username> like every other host.
  # Changing this needs one WSL restart (docs/runbooks/add-nixos-host.md, WSL).
  wsl.defaultUser = userConfig.username;
  # Let Windows .exe's (code.exe, explorer.exe, clip.exe) run from the shell.
  wsl.interop.includePath = true;
  # Expose .desktop entries where WSLg looks, so GUI apps (Orca) get Windows
  # Start-menu shortcuts under "NixOS" — pinnable to the taskbar/Start.
  wsl.startMenuLaunchers = true;

  networking.hostName = "nixos-wsl";
  time.timeZone = "Asia/Tokyo";

  # claude-code and the Orca AppImage are unfree. System level, so it covers
  # home.packages too (useGlobalPkgs in lib/mk-home.nix).
  nixpkgs.config.allowUnfree = true;

  # A real local Docker engine inside the distro (no Docker Desktop on this
  # PC). The group lets the user talk to the socket without sudo.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  users.users.${userConfig.username}.extraGroups = [ "docker" ];

  # At SYSTEM level because it comes from `self.packages` (only threaded into
  # system specialArgs — see hosts/nixos-desktop/default.nix). GUI runs via WSLg.
  environment.systemPackages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.orca
  ];

  # Fonts for the WSLg GUI apps (Orca's terminal, Chrome). The base image ships
  # only DejaVu Sans — no monospace and no Nerd Font, so the starship prompt's
  # icon glyphs rendered as boxes. Same Nerd Fonts as modules/darwin/fonts.nix,
  # plus Noto for Japanese/Vietnamese text and emoji.
  #
  # Unlike macOS, fontconfig lets us make the Nerd Font the default `monospace`,
  # so apps that ask for "monospace" (Orca's terminal included) pick it up
  # without per-app settings.
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK JP"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK JP"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK JP"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # The release this distro was INSTALLED from — a record, not a version to
  # keep current.
  system.stateVersion = "26.05";
}
