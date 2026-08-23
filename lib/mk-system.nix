# The builders: hostPath -> a complete system configuration.
#
# This is the only file that knows how the layers stack up. Everything it
# assembles is either reusable (modules/) or owned by the machine
# (hosts/<name>/), and the split is deliberate — a builder that grew a
# per-host special case would put machine knowledge back into shared code.
#
# What each builder composes, in module-list order:
#   1. the platform base       modules/darwin | modules/nixos
#   2. the host's system module hosts/<name>/default.nix
#   3. home-manager, wired by  ./mk-home.nix, which itself pulls in the
#      platform home entry (modules/*/home -> modules/home-shared) plus
#      hosts/<name>/home.nix
#   4. darwin only: nix-homebrew
#
# The Nix module system MERGES all of these rather than applying them in
# sequence, so ordering here is presentation, not precedence: a shared module
# marks a value lib.mkDefault and the host simply assigns over it.
#
# No `system` argument is passed to darwinSystem/nixosSystem on purpose — each
# host declares its own `nixpkgs.hostPlatform`, which keeps the platform next
# to the machine it describes instead of here.
#
# `identity` is the global user (flake.nix), handed to every module as
# `userConfig` through specialArgs so nothing has to hardcode a username.
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
  # hostPath is a DIRECTORY containing default.nix + home.nix, e.g.
  # ./hosts/macbook. Both files are required; a host without a home.nix would
  # fail here rather than silently skipping its user config.
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
