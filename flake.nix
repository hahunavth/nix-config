# The one entry point. Everything here is either an input pin, the global
# identity, or a list of things to build — no machine-specific settings, which
# live in hosts/<name>/ (see hosts/AGENTS.md).
#
# Two nixpkgs are pinned on purpose: the darwin branch has the best macOS
# binary cache, the nixos branch the best Linux one. Both track the same 26.05
# release, so the two platforms never drift a release apart.
#
# Outputs: darwinConfigurations / nixosConfigurations (one attr per machine,
# named by hostname), packages + checks (pkgs/), devShells (shells/),
# apps.build-switch, and formatter (treefmt.nix).
{
  description = "macOS + NixOS system configuration (nix-darwin + home-manager)";

  inputs = {
    # macOS system layer. nixpkgs follows the *darwin* branch: same 26.05
    # release, but built for darwin, so the cache hit rate is far better.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Linux hosts get their own nixpkgs (nixos branch, same release). Kept
    # separate rather than `follows` so neither platform pays the other's
    # cache misses.
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-26.05";

    # User environment, used by both platforms. useGlobalPkgs (lib/mk-home.nix)
    # makes it reuse the system's pkgs rather than instantiating its own.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Manages the Homebrew *installation* (not just the package lists), so
    # /opt/homebrew is owned by nix too. Consumed in modules/darwin/homebrew.
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Secrets management (age-encrypted; see modules/home-shared/programs/secrets.nix).
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

      # The single user, shared by every host — the one thing deliberately NOT
      # delegated to hosts/, because duplicating it per machine is how the
      # commit email on one of them silently goes stale. Threaded to every
      # module as `userConfig` via specialArgs (lib/mk-system.nix); modules must
      # read it from there and never hardcode a name or address.
      identity = {
        username = "kod_admin";
        fullName = "hahunavth";
        githubUsername = "hahunavth";
        email = "vuthanhha.2001@gmail.com"; # personal (git default)
        workEmail = "vuthanhha@kodnet.co.jp"; # used under KOD folders (see git.nix)
        signingKey = "";
      };

      # Darwin/NixOS builders. Each takes a host directory (hosts/<name>/).
      inherit (import ./lib/mk-system.nix { inherit inputs identity; }) mkDarwin mkNixos;

      # The per-system outputs (packages, checks, devShells, apps, formatter)
      # instantiated for every system this repo can be evaluated from, each
      # against the nixpkgs that matches its platform.
      forAllSystems =
        f:
        lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-linux"
          ]
          (
            system:
            f (
              if lib.hasSuffix "linux" system then
                # allowUnfree so the packages/checks outputs can evaluate unfree
                # Linux apps (e.g. pkgs/claude-desktop). darwin sets the same in
                # modules/darwin/configuration.nix.
                import nixpkgs-linux {
                  inherit system;
                  config.allowUnfree = true;
                }
              else
                nixpkgs.legacyPackages.${system}
            )
          );
    in
    {
      # The host registry — listed explicitly rather than discovered by globbing
      # hosts/, so adding a directory is never enough to start building for a
      # machine. The attr NAME is the hostname darwin-rebuild / nixos-rebuild
      # match on; the value is that machine's directory.
      darwinConfigurations."KOD-ADMINs-MacBook-Pro" = mkDarwin ./hosts/macbook;

      nixosConfigurations = {
        nixos = mkNixos ./hosts/nixos;
        nixos-desktop = mkNixos ./hosts/nixos-desktop;
      };

      # Custom derivations (pkgs/), buildable on their own:
      # `nix build .#atlassian-plugin-sdk-9_1_1`.
      packages = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

      # Same set again as `checks`, so `nix flake check` and CI actually BUILD
      # them. These are all fetchurl pins against upstream servers, and the
      # failure mode worth catching early is an upstream that moved or rehashed
      # a tarball — otherwise you find out mid-rebuild.
      checks = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

      # Ad-hoc project shells (shells/). Complement mise, which owns pinned
      # per-project runtimes; these are for a reproducible one-off entry.
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

      # `nix run .#build-switch` — one command that works on any host: it reads
      # the machine's own hostname and switches to the matching attr, so no
      # per-machine alias has to know which config it is.
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

      # `nix fmt` — treefmt, configured in ./treefmt.nix.
      formatter = forAllSystems (
        pkgs: (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
      );
    };
}
