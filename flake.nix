{
  description = "Darwin system flake";

  inputs = {
    # Nix darwin
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      darwinUser = "kod_admin";
      darwinHost = "KOD-ADMINs-MacBook-Pro";

      mkDarwinSystem = { hostname, username }: nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/${hostname}
          home-manager.darwinModules.home-manager
          {
            users.users.${username}.home = "/Users/${username}";
            system.primaryUser = username;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Automatically back up any pre-existing files that would
            # otherwise be clobbered (e.g. ~/Applications/Home Manager Apps)
            home-manager.backupFileExtension = "backup";

            # Use extraSpecialArgs to pass the username down to home/ safely
            home-manager.extraSpecialArgs = { inherit username; };

            home-manager.users.${username} = import ./home;
          }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          # This passes 'username' and 'hostname' safely into the host modules
          inherit username hostname;
        };
      };

      pkgs = nixpkgs.legacyPackages.aarch64-darwin;

    in {
      darwinConfigurations.${darwinHost} = mkDarwinSystem {
        hostname = darwinHost;
        username = darwinUser;
      };

      # Dev shell for editing this config repo (enter with `nix develop`)
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style   # formatter
          statix             # anti-pattern linter
          deadnix            # dead-code finder
          nil                # Nix LSP (editor completion)
        ];
      };

      # `nix fmt` formats every .nix file
      formatter.aarch64-darwin = pkgs.nixfmt-rfc-style;
    };
}
