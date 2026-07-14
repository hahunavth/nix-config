# System builders: turn a host directory into a darwin/nixos configuration.
#
# A host owns its config in hosts/<name>/ (default.nix = system module, home.nix =
# home module). These builders add the reusable layers around it: the platform
# base (modules/darwin | modules/nixos), the shared home core (modules/*/home),
# the sops HM module, and (darwin) nix-homebrew. The host's default.nix sets its
# own `nixpkgs.hostPlatform`, so no `system` arg is passed to darwin/nixosSystem.
#
# `identity` (username + emails + github) is global and threaded to every module
# as `userConfig` via specialArgs.
{
  inputs,
  identity,
}:
let
  inherit (inputs)
    self
    nix-darwin
    nixpkgs-linux
    home-manager
    nix-homebrew
    sops-nix
    ;
  mkHome = import ./mk-home.nix;
  sharedModules = [ sops-nix.homeManagerModules.sops ];
in
{
  # hostPath e.g. ./hosts/macbook — a directory with default.nix + home.nix.
  mkDarwin =
    hostPath:
    nix-darwin.lib.darwinSystem {
      specialArgs = {
        userConfig = identity;
        inherit self;
      };
      modules = [
        # Shared macOS platform layer
        ../modules/darwin
        # This host's own system config
        (hostPath + "/default.nix")
        # User environment: shared core + this host's home
        home-manager.darwinModules.home-manager
        (mkHome {
          userConfig = identity;
          inherit sharedModules;
          homePrefix = "/Users";
          entry = ../modules/darwin/home;
          hostHome = hostPath + "/home.nix";
        })
        # Homebrew installation module
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };

  mkNixos =
    hostPath:
    nixpkgs-linux.lib.nixosSystem {
      specialArgs = {
        userConfig = identity;
        inherit self;
      };
      modules = [
        # Shared NixOS platform layer
        ../modules/nixos
        # This host's own system config (hardware/desktop, or OrbStack)
        (hostPath + "/default.nix")
        # User environment: shared core + this host's home
        home-manager.nixosModules.home-manager
        (mkHome {
          userConfig = identity;
          inherit sharedModules;
          homePrefix = "/home";
          entry = ../modules/nixos/home;
          hostHome = hostPath + "/home.nix";
        })
      ];
    };
}
