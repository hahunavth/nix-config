# Hand-maintained NixOS base, applied to EVERY Linux host — lib/mk-system.nix
# adds modules/nixos to both `nixos` (OrbStack VM) and `nixos-desktop`. So keep
# only cross-host settings here; anything that suits one machine belongs in its
# hosts/<name>/default.nix.
#
# Not to be confused with ./orbstack/, which is the OrbStack guest integration
# (bootless lxc-container base, the kod_admin user, hostname, timezone,
# sshd-disabled, DNS, certs, stateVersion). Those files are copied verbatim from
# the VM's /etc/nixos, are imported only by hosts/nixos, and should be re-synced
# (and diffed) if OrbStack regenerates them.
{ pkgs, userConfig, ... }:

{
  # Same policy as modules/darwin/nix-settings.nix, different spellings. Keep
  # the two in step — divergence here is how the hosts start behaving
  # differently for reasons nobody remembers.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ userConfig.username ];
  };

  # Weekly GC + store dedup, matching the darwin side. systemd calendar events
  # here where darwin uses a launchd interval.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # home-manager writes the zsh CONFIG, but NixOS still has to bless zsh as a
  # login shell (it must appear in /etc/shells) before it can be one.
  #
  # The shell is set via users.defaultUserShell rather than on the user, because
  # the OrbStack-generated config already defines kod_admin with
  # `useDefaultShell = true`. Redefining that user here would conflict with a
  # file we do not hand-edit; moving the default instead sidesteps it.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Only what has to exist before a user profile does, or what mise needs to
  # build a tool from source. Language runtimes themselves come from mise
  # (modules/home-shared/programs/mise.nix), not from here.
  environment.systemPackages = with pkgs; [
    git
    curl
    gnumake
    gcc
    python3 # mise's node plugin needs it if it ever falls back to source builds
  ];

  # Load-bearing for mise on NixOS. mise downloads PREBUILT binaries, which are
  # linked against /lib64/ld-linux-*.so — a path NixOS does not have. nix-ld
  # provides that interpreter shim.
  #
  # Without it every mise-installed JDK, node and pnpm fails with "No such file
  # or directory", naming a file that plainly exists — one of the more
  # misleading errors on NixOS.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    zlib # JDKs and node dlopen libz at runtime
  ];

  # NOTE: sshd stays disabled (see orbstack/orbstack.nix) — OrbStack provides SSH
  # itself (`ssh nixos@orb` / `orb -m nixos`). Do not enable services.openssh.
}
