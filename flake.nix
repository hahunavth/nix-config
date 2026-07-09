{
  description = "Darwin system flake";

  inputs = {
    # Nix darwin (nixpkgs tracks the darwin branch, best cache for macOS)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nixpkgs for Linux (NixOS) hosts — same 26.05 release, nixos branch.
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Home manager (cross-platform; with useGlobalPkgs it uses each system's pkgs)
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative management of the Homebrew installation itself
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-linux,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # Machine registry: hosts.nix entries, validated and enriched by lib/hosts.nix
      hostConfig = import ./lib/hosts.nix { hostsPath = ./hosts.nix; };
      inherit (hostConfig) validatedConfigsChecked;

      # Partition hosts by platform (userConfig.system, e.g. aarch64-darwin).
      isDarwinHost = h: lib.hasSuffix "darwin" h.system;
      darwinHosts = builtins.filter isDarwinHost validatedConfigsChecked;
      nixosHosts = builtins.filter (h: !isDarwinHost h) validatedConfigsChecked;

      mkDarwinConfiguration =
        userConfig:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit userConfig self; };
          modules = [
            { nixpkgs.hostPlatform = userConfig.system; }

            # System configuration (darwin/)
            ./darwin/configuration.nix
            ./darwin/nix-settings.nix
            ./darwin/misc-system.nix
            ./darwin/security.nix
            ./darwin/linux-builder.nix
            ./darwin/fonts.nix
            ./darwin/macos-defaults.nix
            ./darwin/raycast-beta.nix

            # User environment (home-manager/)
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # Automatically back up any pre-existing files that would
                # otherwise be clobbered (e.g. ~/Applications/Home Manager Apps)
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit userConfig; };
                users.${userConfig.username} =
                  { lib, ... }:
                  {
                    imports = [ ./home-manager/darwin.nix ];
                    home = {
                      username = lib.mkForce userConfig.username;
                      # lib.mkForce works around nix-darwin issue #682
                      homeDirectory = lib.mkForce "/Users/${userConfig.username}";
                      # home-manager version (be careful when changing)
                      stateVersion = "26.05";
                    };
                    programs.home-manager.enable = true;
                  };
              };
            }

            # Homebrew (installation + composed package lists)
            nix-homebrew.darwinModules.nix-homebrew
            ./darwin/homebrew.nix
          ];
        };

      mkNixosConfiguration =
        userConfig:
        nixpkgs-linux.lib.nixosSystem {
          specialArgs = { inherit userConfig self; };
          modules = [
            { nixpkgs.hostPlatform = userConfig.system; }

            # OrbStack-generated guest integration (copied from the VM's
            # /etc/nixos; re-sync if OrbStack regenerates it) + our system layer.
            ./nixos/orbstack/configuration.nix
            ./nixos/configuration.nix

            # User environment (home-manager/)
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit userConfig; };
                users.${userConfig.username} =
                  { lib, ... }:
                  {
                    imports = [ ./home-manager/linux.nix ];
                    home = {
                      username = lib.mkForce userConfig.username;
                      homeDirectory = lib.mkForce "/home/${userConfig.username}";
                      stateVersion = "26.05";
                    };
                    programs.home-manager.enable = true;
                  };
              };
            }
          ];
        };

      # devShell / formatter for both the Mac and the Linux VM. Pick pkgs from
      # the matching nixpkgs per system.
      forAllSystems =
        f:
        lib.genAttrs [ "aarch64-darwin" "aarch64-linux" ] (
          system:
          f (
            if lib.hasSuffix "linux" system then
              nixpkgs-linux.legacyPackages.${system}
            else
              nixpkgs.legacyPackages.${system}
          )
        );
    in
    {
      # macOS hosts: darwin-rebuild selects by hostname.
      darwinConfigurations = builtins.listToAttrs (
        builtins.map (userConfig: {
          name = userConfig.hostname;
          value = mkDarwinConfiguration userConfig;
        }) darwinHosts
      );

      # Linux (NixOS) hosts: nixos-rebuild selects by hostname.
      nixosConfigurations = builtins.listToAttrs (
        builtins.map (userConfig: {
          name = userConfig.hostname;
          value = mkNixosConfiguration userConfig;
        }) nixosHosts
      );

      # Dev shell for editing this config repo (enter with `nix develop`)
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style # formatter
            statix # anti-pattern linter
            deadnix # dead-code finder
            nil # Nix LSP (editor completion)
          ];
        };
      });

      # `nix fmt` formats every .nix file
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
