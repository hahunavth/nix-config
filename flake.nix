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
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            networking.hostName = hostname;
            users.users.${username}.home = "/Users/${username}";
            system.primaryUser = username;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Automatically back up any pre-existing files that would
            # otherwise be clobbered (e.g. ~/Applications/Home Manager Apps)
            home-manager.backupFileExtension = "backup";
            
            # FIX 1: Use extraSpecialArgs to pass the username down to home.nix safely
            home-manager.extraSpecialArgs = { inherit username; };
            
            # FIX 2: Point straight to the file. Home Manager will handle the import cleanly.
            home-manager.users.${username} = import ./home.nix;
          }
        ];
        specialArgs = {
          inherit (nixpkgs) lib;
          inherit username; # This passes 'username' safely into configuration.nix
        };
      };

      # raycast beta
      raycastBeta = pkgs: import ./raycast-beta.nix { inherit pkgs; lib = pkgs.lib; };

    in {
      darwinConfigurations.${darwinHost} = mkDarwinSystem {
        hostname = darwinHost;
        username = darwinUser;
      };
    };
}
