# Host inventory: shared identity in common.nix, one file per machine.
{
  common = import ./common.nix;

  hosts = {
    work = import ./work.nix;

    # Headless NixOS dev VM running under OrbStack on the Mac.
    # Reached from the Mac via `ssh nixos@orb` / `orb -m nixos`; the flake is
    # visible inside the VM at /private/etc/nix-darwin (Mac virtiofs mount).
    nixos = import ./nixos.nix;

    # personal = {
    #   username = "...";
    #   hostname = "...";
    #   profile = "personal";
    #   system = "aarch64-darwin";
    # };
  };
}
