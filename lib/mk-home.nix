# The home-manager half of a build, identical on both platforms.
#
# Returns just the `home-manager` config block. The platform HM module itself
# (home-manager.{darwin,nixos}Modules.home-manager) is added by mk-system.nix —
# splitting it this way is what lets darwin and nixos share every option below
# while differing only in the two arguments that genuinely differ per platform
# (where homes live, and which home entry point to import).
#
# Args:
#   userConfig     global identity from flake.nix, forwarded to HM modules as
#                  `userConfig` via extraSpecialArgs
#   homePrefix     "/Users" (darwin) or "/home" (linux)
#   entry          platform home entry point (modules/{darwin,nixos}/home),
#                  which imports modules/home-shared
#   hostHome       the machine's own home module (hosts/<name>/home.nix)
#   sharedModules  extra HM modules for every user (currently sops-nix)
{
  userConfig,
  homePrefix,
  entry,
  hostHome,
  sharedModules ? [ ],
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Rename rather than refuse: home-manager aborts the whole activation if a
    # file it wants to write already exists unmanaged, which on a fresh machine
    # means one stray dotfile blocks the first switch. The displaced file is
    # kept as <name>.backup.
    backupFileExtension = "backup";
    inherit sharedModules;
    extraSpecialArgs = { inherit userConfig; };
    users.${userConfig.username} =
      { lib, ... }:
      {
        # Platform layer first, then the host's own — siblings, not nested, so
        # the module system merges them and the host can override by plain
        # assignment over a shared lib.mkDefault.
        imports = [
          entry
          hostHome
        ];
        home = {
          username = lib.mkForce userConfig.username;
          # mkForce works around nix-darwin issue #682, where nix-darwin also
          # sets homeDirectory and the two definitions conflict.
          homeDirectory = lib.mkForce "${homePrefix}/${userConfig.username}";
          # Records which home-manager release's DEFAULTS this profile was
          # built against — not a version to keep current. Bumping it silently
          # changes option defaults under you; leave it pinned.
          stateVersion = "26.05";
        };
        programs.home-manager.enable = true;
      };
  };
}
