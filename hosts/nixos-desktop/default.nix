# nixos-desktop — x86_64 GUI VM (GNOME) running under VirtualBox. This host owns
# its system config: hardware, boot, user, locale, services. The shared NixOS base
# (../../modules/nixos) is added by lib/mk-system.nix; the reusable GUI layer is
# ../../modules/nixos/desktop. hardware-configuration.nix is generated on the VM
# (docs/runbooks/add-nixos-host.md).
{
  pkgs,
  self,
  userConfig,
  ...
}:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ./hardware-configuration.nix # generated on the VM
    ../../modules/nixos/desktop # GNOME + VM guest tools
  ];

  # BIOS/legacy boot via GRUB on the VirtualBox disk (matches the default install).
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos-desktop";
  networking.networkmanager.enable = true;

  # Locale: US English with Vietnamese regional formats (from the install).
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  time.timeZone = "Asia/Ho_Chi_Minh";

  # vscode, google-chrome, teamviewer and claude-desktop are unfree. useGlobalPkgs
  # (lib/mk-home.nix) makes this cover home.packages too.
  nixpkgs.config.allowUnfree = true;

  # Normal login user. home-manager manages the home; login shell comes from the
  # shared `users.defaultUserShell = pkgs.zsh`. Change the password after first login.
  users.users.${userConfig.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    initialPassword = "changeme";
  };

  # Remote access.
  services.openssh.enable = true; # ssh (opens port 22)
  services.xrdp.enable = true; # rdp — starts an Xorg GNOME session
  services.xrdp.defaultWindowManager = "gnome-session";
  services.xrdp.openFirewall = true; # opens port 3389
  services.teamviewer.enable = true; # daemon + app (unfree; manages its own connectivity)

  # GUI apps packaged from upstream .debs (pkgs/{claude-desktop,opencode-desktop}).
  # Installed at system level because `self` is only in the system specialArgs, not home.nix.
  environment.systemPackages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    self.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
  ];

  # Set to the NixOS release you installed from; do not bump casually.
  system.stateVersion = "26.05";
}
