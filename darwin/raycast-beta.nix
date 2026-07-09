{
  pkgs,
  lib,
  userConfig,
  ...
}:

let
  # raycast beta
  raycastBetaDmg = import ../pkgs/raycast-beta {
    inherit pkgs;
    lib = pkgs.lib;
  };

in
{
  # raycast beta
  # mkBefore runs this before the home-manager activation (same order as before the refactor)
  system.activationScripts.postActivation.text = lib.mkBefore ''
    if [ ! -e "/Applications/Raycast Beta.app" ]; then
      echo "Installing Raycast Beta..."
      MOUNT_POINT=$(mktemp -d)
      hdiutil attach "${raycastBetaDmg}" -nobrowse -mountpoint "$MOUNT_POINT"
      cp -R "$MOUNT_POINT/Raycast Beta.app" /Applications/
      hdiutil detach "$MOUNT_POINT"
      rmdir "$MOUNT_POINT"
      chmod -R u+w "/Applications/Raycast Beta.app"
    fi
    # This script runs as root, so a fresh install ends up root-owned — which
    # breaks Raycast's in-app updater (it quits the app, fails to replace the
    # bundle, and never relaunches). Keep the bundle owned by the user.
    # NOTE: macOS App Management protection can block even root here; the
    # terminal running darwin-rebuild needs the "App Management" permission
    # (System Settings → Privacy & Security → App Management).
    if [ -e "/Applications/Raycast Beta.app" ] \
        && [ "$(stat -f %Su "/Applications/Raycast Beta.app")" != "${userConfig.username}" ]; then
      if chown -R ${userConfig.username}:staff "/Applications/Raycast Beta.app" 2>/dev/null; then
        echo "fixed Raycast Beta ownership (${userConfig.username})" >&2
      else
        echo "warning: could not fix Raycast Beta ownership; grant App Management" >&2
        echo "warning: to your terminal in System Settings → Privacy & Security" >&2
      fi
    fi
  '';
}
