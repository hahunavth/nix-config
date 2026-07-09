{ pkgs, userConfig, ... }:

{
  # nix-darwin manages nix-daemon automatically when nix.enable is on
  nix.package = pkgs.nix;

  nix.settings = {
    # Enable flakes etc. by default (no more --extra-experimental-features)
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # The daemon must trust the admin user (needed e.g. to offload builds to
    # the linux-builder). root is always trusted implicitly.
    trusted-users = [ userConfig.username ];
  };

  # Garbage collection (every Sunday 4:00, delete generations older than 30 days)
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 4;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  # Deduplicate the nix store
  nix.optimise.automatic = true;
}
