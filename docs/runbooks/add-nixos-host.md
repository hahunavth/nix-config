# Runbook: add a NixOS host

A NixOS host is a directory `hosts/<name>/` (owning its system + home config) plus
one line in `flake.nix`. The shared NixOS base (`modules/nixos`) and the shared home
core come for free via the builder.

## 1. Create the host directory

`hosts/<name>/default.nix` — system module: sets `nixpkgs.hostPlatform`,
`networking.hostName`, bootloader, the login user (`isNormalUser`), timezone,
`system.stateVersion`, and imports its reusable pieces:

```nix
{ lib, userConfig, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  imports = [ ./hardware-configuration.nix ../../modules/nixos/desktop ];
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  networking.hostName = "myhost";
  networking.networkmanager.enable = true;
  users.users.${userConfig.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "changeme";
  };
  time.timeZone = "Asia/Tokyo";
  system.stateVersion = "25.11";
}
```

`hosts/<name>/home.nix` — home module (`hn.*` toggles + host-only home config). Start
with a **placeholder** `hardware-configuration.nix` (copy `hosts/nixos-desktop/`'s) so
the flake evaluates before the machine exists.

Then list it: `nixosConfigurations.myhost = mkNixos ./hosts/myhost;` in `flake.nix`.

## 2. Generate the real hardware config (on the machine)

Install NixOS, then:

```bash
sudo nixos-generate-config --show-hardware-config
```

Paste its output over `hosts/<name>/hardware-configuration.nix`; set
`system.stateVersion` to the release you installed. Leave `nixpkgs.hostPlatform` in
`default.nix` as-is.

## 3. Build & switch — ON the target machine

```bash
git add -A
sudo nixos-rebuild switch --flake .#myhost
```

x86_64-linux cannot be built from the aarch64 Mac — build on the host itself.

## Verify from the Mac (eval only)

```bash
nix eval .#nixosConfigurations.myhost.config.system.build.toplevel.drvPath
```
