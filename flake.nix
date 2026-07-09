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
      # Machine registry: hostname -> { username, profile }.
      # `profile` selects the profiles/<profile>.nix package overrides.
      hosts = {
        "KOD-ADMINs-MacBook-Pro" = { username = "kod_admin"; profile = "work"; };
        # future: "Personal-MBP" = { username = "..."; profile = "personal"; };
      };

      mkDarwinSystem = { hostname, username, profile }: nix-darwin.lib.darwinSystem {
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

            # Pass username + profile down to home/ modules
            home-manager.extraSpecialArgs = { inherit username profile; };

            home-manager.users.${username} = import ./home;
          }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          # Pass username / hostname / profile safely into the host modules
          inherit username hostname profile;
        };
      };

      pkgs = nixpkgs.legacyPackages.aarch64-darwin;

    in {
      darwinConfigurations = nixpkgs.lib.mapAttrs (
        hostname: h: mkDarwinSystem { inherit hostname; inherit (h) username profile; }
      ) hosts;

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
