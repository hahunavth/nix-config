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

    # Declarative management of the Homebrew installation itself
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      system = "aarch64-darwin";

      # Machine registry: hosts.nix entries, validated and enriched by lib/hosts.nix
      hostConfig = import ./lib/hosts.nix { hostsPath = ./hosts.nix; };
      inherit (hostConfig) validatedConfigsChecked;

      mkDarwinConfiguration =
        userConfig:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit userConfig self; };
          modules = [
            { nixpkgs.hostPlatform = system; }

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
                    imports = [ ./home-manager/default.nix ];
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

      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # One entry per hosts.nix host; darwin-rebuild selects by hostname.
      darwinConfigurations = builtins.listToAttrs (
        builtins.map (userConfig: {
          name = userConfig.hostname;
          value = mkDarwinConfiguration userConfig;
        }) validatedConfigsChecked
      );

      # Dev shell for editing this config repo (enter with `nix develop`)
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style # formatter
          statix # anti-pattern linter
          deadnix # dead-code finder
          nil # Nix LSP (editor completion)
        ];
      };

      # `nix fmt` formats every .nix file
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
