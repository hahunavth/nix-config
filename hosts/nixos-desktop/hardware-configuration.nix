# Generated on the VirtualBox VM by `nixos-generate-config` — do not hand-edit.
# Re-generate and paste over this file if the VM's disks/hardware change.
#
# nixpkgs.hostPlatform is intentionally omitted here: the host's default.nix
# owns it (see hosts/nixos-desktop/default.nix).
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "ohci_pci"
    "ehci_pci"
    "ahci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/72427b2d-ca38-4402-9481-20ed0b6f38c7";
    fsType = "ext4";
  };

  swapDevices = [ ];

  virtualisation.virtualbox.guest.enable = true;
}
