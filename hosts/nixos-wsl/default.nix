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
  # Do NOT append the whole Windows PATH (wsl.conf appendWindowsPath). It
  # carries ~40 dirs, several shadowing the Linux toolchain: Windows node, a
  # broken global pnpm shim, CRLF corepack, JDK 8, Python, Git, OpenSSH,
  # ripgrep — and it lands ahead of the mise shims in non-interactive shells
  # (agents, scripts), where `mise activate` never runs. Needs a WSL restart.
  wsl.wslConf.interop.appendWindowsPath = false;
  wsl.interop.includePath = false;
  # Windows interop itself stays on; re-add only the few Windows tools worth
  # having, at the END of PATH so they can never shadow a Linux binary.
  environment.extraInit = ''
    export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Users/${userConfig.username}/AppData/Local/Programs/Microsoft VS Code/bin"
  '';
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

  # The checkout lives at ~/nix-config, but app repos shared with the Mac load
  # dev shells by the Mac's path (`use flake /etc/nix-darwin#mobile` in their
  # .envrc). Point that path here so those .envrc files work unchanged and
  # give the project adb, ANDROID_HOME and JDK 17.
  environment.etc."nix-darwin".source = "/home/${userConfig.username}/nix-config";

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
