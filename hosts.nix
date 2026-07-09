# Machine & identity registry (see hosts.example.nix for the template).
# Validated and enriched by lib/hosts.nix; the flake builds one
# darwinConfigurations entry per host below.
{
  common = {
    fullName = "hahunavth";
    githubUsername = "hahunavth";
    # Personal identity is the git default everywhere...
    email = "vuthanhha.2001@gmail.com";
    # ...but repos under a KOD folder use the work identity (see modules/git.nix).
    workEmail = "vuthanhha@kodnet.co.jp";
    signingKey = ""; # Set when commit signing is configured
  };

  hosts = {
    work = {
      username = "kod_admin";
      hostname = "KOD-ADMINs-MacBook-Pro";
      profile = "work";
      system = "aarch64-darwin";
    };

    # Headless NixOS dev VM running under OrbStack on the Mac.
    # Reached from the Mac via `ssh nixos@orb` / `orb -m nixos`; the flake is
    # visible inside the VM at /private/etc/nix-darwin (Mac virtiofs mount).
    # `profile` is unused on Linux (Homebrew-only) but must be a valid value.
    nixos = {
      username = "kod_admin";
      hostname = "nixos";
      profile = "personal";
      system = "aarch64-linux";
    };

    # personal = {
    #   username = "...";
    #   hostname = "...";
    #   profile = "personal";
    #   system = "aarch64-darwin";
    # };
  };
}
