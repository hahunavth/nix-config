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

    # Secrets management (age-encrypted; see home-manager/modules/secrets.nix).
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Multi-language formatter wiring for `nix fmt` (config in ./treefmt.nix).
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-linux,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # Machine registry: hosts/ entries, validated and enriched by lib/hosts.nix
      hostConfig = import ./lib/hosts.nix { hostsPath = ./hosts; };
      inherit (hostConfig) validatedConfigsChecked;

      # Partition hosts by platform (userConfig.system, e.g. aarch64-darwin).
      isDarwinHost = h: lib.hasSuffix "darwin" h.system;
      darwinHosts = builtins.filter isDarwinHost validatedConfigsChecked;
      nixosHosts = builtins.filter (h: !isDarwinHost h) validatedConfigsChecked;

      # Darwin/NixOS builders (shared home-manager wiring lives in lib/mk-home.nix).
      inherit (import ./lib/mk-system.nix { inherit inputs; }) mkDarwin mkNixos;

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
          value = mkDarwin userConfig;
        }) darwinHosts
      );

      # Linux (NixOS) hosts: nixos-rebuild selects by hostname.
      nixosConfigurations = builtins.listToAttrs (
        builtins.map (userConfig: {
          name = userConfig.hostname;
          value = mkNixos userConfig;
        }) nixosHosts
      );

      # Custom packages (pkgs/), exported per system. Build one with
      # `nix build .#raycast-beta`.
      packages = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

      # `nix flake check` builds these, so a rotted fetchurl URL/hash fails loudly
      # instead of only at rebuild time.
      checks = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

      # Project dev shells (shells/), entered with `nix develop .#<name>`.
      devShells = forAllSystems (
        pkgs:
        let
          importShell = name: import (./shells + "/${name}.nix") { inherit pkgs; };
        in
        {
          default = importShell "default";
          atlassian = importShell "atlassian";
          node = importShell "node";
          python = importShell "python";
        }
      );

      # `nix run .#build-switch` — build + switch the CURRENT machine's config,
      # picking the darwinConfigurations/nixosConfigurations entry by hostname.
      apps = forAllSystems (
        pkgs:
        let
          isDarwin = pkgs.stdenv.isDarwin;
          rebuild = if isDarwin then "darwin-rebuild" else "nixos-rebuild";
          flakeDir = if isDarwin then "/etc/nix-darwin" else "/private/etc/nix-darwin";
          hostCmd = if isDarwin then "scutil --get LocalHostName" else "hostname -s";
          script = pkgs.writeShellScript "build-switch" ''
            set -euo pipefail
            host="$(${hostCmd})"
            echo "Building + switching (${rebuild}) for host: $host"
            exec sudo ${rebuild} switch --flake "${flakeDir}#$host"
          '';
        in
        {
          build-switch = {
            type = "app";
            program = "${script}";
          };
        }
      );

      # `nix fmt` runs treefmt (config in ./treefmt.nix) — nixfmt over all .nix
      # files except the generated/vendored trees.
      formatter = forAllSystems (
        pkgs: (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
      );
    };
}
