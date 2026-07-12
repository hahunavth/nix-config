# Runbook: add a host

A host is a directory `hosts/<name>/` that **owns its config**, plus one line in
`flake.nix`. The reusable layers (`modules/{shared,darwin,nixos}`) and the shared
home core are added by the builder.

## 1. Create the host directory

`hosts/<name>/default.nix` — the system module:

```nix
{ ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin"; # or x86_64/aarch64-linux
  networking = {
    hostName = "My-MBP";
    computerName = "My-MBP";
    localHostName = "My-MBP";
  };
  # macOS: this host's own casks (merge with the shared base)
  homebrew.casks = [ "some-app" ];
}
```

`hosts/<name>/home.nix` — the home module (feature toggles + host-only user config):

```nix
{ ... }:
{
  hn.atlassian.enable = true; # opt into features declared in modules/shared/features.nix
}
```

Identity (username, emails, github) is **global** in `flake.nix` (`identity`) — hosts
don't set it. For a NixOS host see [add-nixos-host.md](add-nixos-host.md).

## 2. List it in flake.nix

The attr name is the hostname (darwin-/nixos-rebuild select by it):

```nix
darwinConfigurations."My-MBP" = mkDarwin ./hosts/mymbp;
# or
nixosConfigurations.myhost = mkNixos ./hosts/myhost;
```

## 3. `git add -A`, then verify

```bash
nix eval .#darwinConfigurations.\"My-MBP\".config.system.build.toplevel.drvPath   # eval
nix build .#darwinConfigurations.\"My-MBP\".system                                # macOS
```

## Where host-specific config goes

Everything unique to the machine lives in `hosts/<name>/`: `default.nix` for system
(casks, `system.defaults`, hardware, hostname), `home.nix` for home (feature
toggles, host-only user packages). Shared config stays in `modules/`.
