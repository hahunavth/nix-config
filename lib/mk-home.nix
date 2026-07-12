# Shared home-manager wiring for darwin and nixos systems.
#
# Returns the `home-manager` config block (as a module attrset). The platform HM
# module itself (home-manager.{darwin,nixos}Modules.home-manager) is added by the
# caller — this only carries the shared options + per-user config.
#
# Args:
#   userConfig     global identity (username + emails + github), threaded to HM modules
#   homePrefix     "/Users" (darwin) or "/home" (linux)
#   entry          the platform home entry point (modules/{darwin,nixos}/home)
#   hostHome       the host's own home module (hosts/<name>/home.nix)
#   sharedModules  extra HM modules applied to every user (e.g. sops-nix)
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
    # Back up any pre-existing files that would otherwise be clobbered
    # (e.g. ~/Applications/Home Manager Apps).
    backupFileExtension = "backup";
    inherit sharedModules;
    extraSpecialArgs = { inherit userConfig; };
    users.${userConfig.username} =
      { lib, ... }:
      {
        imports = [
          entry
          hostHome
        ];
        home = {
          username = lib.mkForce userConfig.username;
          # lib.mkForce works around nix-darwin issue #682
          homeDirectory = lib.mkForce "${homePrefix}/${userConfig.username}";
          # home-manager version (be careful when changing)
          stateVersion = "26.05";
        };
        programs.home-manager.enable = true;
      };
  };
}
