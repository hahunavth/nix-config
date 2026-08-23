# The nix daemon itself: features, trust, and the two housekeeping jobs.
#
# Mirrored for Linux in modules/nixos/configuration.nix — same intent, different
# option spellings (launchd interval here, systemd calendar there). Changing a
# policy in one place and not the other is how the hosts quietly diverge.
{ pkgs, userConfig, ... }:

{
  # nix-darwin runs and updates nix-daemon for us whenever nix.enable is on
  # (the default), so this only pins which nix that daemon is.
  nix.package = pkgs.nix;

  nix.settings = {
    # Flakes are how this entire repo is consumed, so they are on permanently
    # rather than passed per command.
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Needed for build offloading: an untrusted user's request to use a remote
    # builder (./linux-builder.nix) is ignored by the daemon, silently, and the
    # build just runs locally or fails on the wrong platform. root is always
    # trusted implicitly, hence only the human here.
    trusted-users = [ userConfig.username ];
  };

  # Weekly GC, Sunday 04:00 (Weekday 0 = Sunday in launchd). 30 days is chosen
  # to outlast a broken switch you only notice next week — rolling back needs
  # the old generation to still exist.
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 4;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  # Hard-link identical files across store paths. Pays off here because several
  # closures (three hosts, plus every generation) overlap heavily.
  nix.optimise.automatic = true;
}
