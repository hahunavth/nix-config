{ pkgs, lib, ... }:

let
  # raycast beta
  raycastBetaDmg = import ../../pkgs/raycast-beta { inherit pkgs; lib = pkgs.lib; };

in
{
  # raycast beta
  # mkBeforeで、home-managerのactivationより前に実行する（リファクタリング前と同じ順序）
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
  '';
}
