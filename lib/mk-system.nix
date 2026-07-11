# System builders: turn a validated userConfig into a darwin/nixos configuration.
# Keeps flake.nix thin — the two builders differ only in platform module, HM
# module, home prefix, entry point, and (darwin-only) the nix-homebrew module.
{ inputs }:
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

  # HM modules applied to every user. sops-nix is present but inert until a host
  # sets `hn.secrets.enable` (see modules/shared/programs/secrets.nix).
  sharedModules = [ sops-nix.homeManagerModules.sops ];
in
{
  mkDarwin =
    userConfig:
    nix-darwin.lib.darwinSystem {
      specialArgs = { inherit userConfig self; };
      modules = [
        { nixpkgs.hostPlatform = userConfig.system; }

        # System configuration (modules/darwin/)
        ../modules/darwin

        # User environment (modules/shared + macOS-only home)
        home-manager.darwinModules.home-manager
        (mkHome {
          inherit userConfig sharedModules;
          homePrefix = "/Users";
          entry = ../modules/darwin/home;
        })

        # Homebrew installation module (darwin/default.nix imports the config)
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };

  mkNixos =
    userConfig:
    nixpkgs-linux.lib.nixosSystem {
      specialArgs = { inherit userConfig self; };
      modules = [
        { nixpkgs.hostPlatform = userConfig.system; }

        # OrbStack-generated guest integration + our shared NixOS layer.
        ../modules/nixos

        # User environment (modules/shared + linux-only home)
        home-manager.nixosModules.home-manager
        (mkHome {
          inherit userConfig sharedModules;
          homePrefix = "/home";
          entry = ../modules/nixos/home;
        })
      ];
    };
}
