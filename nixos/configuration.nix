# Our declarative system layer for the OrbStack NixOS dev VM.
#
# The OrbStack guest integration (bootless lxc-container base, the kod_admin
# user, hostname, timezone, sshd-disabled, DNS, certs, stateVersion) lives in
# ./orbstack/ — those files are copied verbatim from the VM's /etc/nixos and
# should be re-synced (diffed) if OrbStack regenerates them. Keep THIS file for
# everything we add on top.
{ pkgs, userConfig, ... }:

{
  # Flakes + trust the admin user (mirrors darwin/nix-settings.nix).
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ userConfig.username ];
  };

  # Garbage collection + store dedup (NixOS spelling; darwin uses a launchd interval).
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # zsh is configured by home-manager; NixOS needs it enabled system-wide to be
  # a valid login shell. The OrbStack-defined user has `useDefaultShell = true`,
  # so switching the default shell (rather than redefining the user) avoids a
  # conflict with that read-only user definition.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Lean system-level toolchain; language runtimes come via mise + home-manager.
  environment.systemPackages = with pkgs; [
    git
    curl
    gnumake
    gcc
  ];

  # NOTE: sshd stays disabled (see orbstack/orbstack.nix) — OrbStack provides SSH
  # itself (`ssh nixos@orb` / `orb -m nixos`). Do not enable services.openssh.
}
