# nixos-desktop — x86_64 GUI VM (XFCE on Xorg) running under VirtualBox. This host
# owns its system config: hardware, boot, user, locale, services. The shared NixOS base
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
    ../../modules/nixos/desktop # XFCE + VM guest tools
  ];

  # BIOS/legacy GRUB, matching how the VM was actually installed. Do not switch
  # to systemd-boot without also reinstalling the VM as UEFI — it needs an ESP
  # this disk does not have.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos-desktop";
  networking.networkmanager.enable = true;

  # English UI, Vietnamese regional formats (dates, currency, paper size) —
  # carried over from the installer's choices.
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

  # Needed for vscode, google-chrome, teamviewer and claude-desktop. Set at
  # SYSTEM level and it also covers home.packages, because useGlobalPkgs
  # (lib/mk-home.nix) makes home-manager reuse this pkgs instance rather than
  # instantiating its own — otherwise this would have to be repeated in home.nix.
  nixpkgs.config.allowUnfree = true;

  # Unlike the OrbStack host, nothing generated a user here, so this host defines
  # its own. The login shell comes from the shared users.defaultUserShell in
  # modules/nixos/configuration.nix.
  #
  # initialPassword is a plaintext placeholder that lands in the world-readable
  # nix store, and only applies until the account first exists. Change it after
  # first login. Acceptable only because this is a throwaway local VM.
  users.users.${userConfig.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    initialPassword = "changeme";
  };

  # No lock screen. In XFCE the screensaver is what locks the session, so this is
  # the switch — worth having off in a VM, where the host already gates access
  # and a lock just means typing the placeholder password again.
  services.xserver.desktopManager.xfce.enableScreensaver = false;

  # Remote access, all three routes. Unlike the OrbStack host (where sshd stays
  # off because OrbStack provides its own), this VM has no built-in path in, so
  # it opens its own — and these ports are reachable, so keep that in mind
  # alongside the placeholder password above.
  services.openssh.enable = true; # ssh (opens port 22)
  services.xrdp.enable = true; # rdp — serves an Xorg XFCE session
  services.xrdp.defaultWindowManager = "xfce4-session";
  services.xrdp.openFirewall = true; # opens port 3389
  services.teamviewer.enable = true; # daemon + app (unfree; manages its own connectivity)

  # The two Electron apps repacked from upstream .debs. At SYSTEM level purely
  # for a plumbing reason: they are referenced through `self.packages`, and
  # `self` is threaded into specialArgs (system) but not extraSpecialArgs
  # (home) — see lib/mk-system.nix. Everything else this host installs is in
  # ./home.nix.
  environment.systemPackages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    self.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
  ];

  # The release this VM was INSTALLED from — a record, not a version to keep
  # current. Bumping it silently changes option defaults underneath the host.
  system.stateVersion = "26.05";
}
