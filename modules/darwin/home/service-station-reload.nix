# Reload the Service Station Finder Sync extension when a watched external
# volume (re)mounts, so its right-click menu re-binds to the fresh mount.
#
# Why this exists: Service Station (Mac App Store, last updated 2020) stores each
# Finder Location as a sandbox security-scoped bookmark tied to a specific *mount
# instance*. When an external volume is ejected and replugged — even at the same
# /Volumes/<name> path — the bookmark goes stale and the menu silently stops
# appearing on that volume. Killing the app doesn't help: the menu is drawn by a
# Finder Sync *extension* (com.knurling.ServiceStation.FinderSync) hosted by
# PlugInKit, not by the app process.
#
# Fix: on a volume (re)mount, disable+re-enable the extension via `pluginkit` and
# (optionally) relaunch Finder so it re-spawns the extension against the new mount.
#
# WatchPaths fires only for the configured volume paths (created/removed), so
# unrelated .dmg / network / USB mounts do NOT trigger a Finder relaunch. The
# per-path `[ -d ]` guard makes the job a no-op on unmount.
#
# Caveat: with restartFinder = true, a relaunch aborts any in-progress *Finder*
# copy/move (those run inside the Finder process). Terminal/app/cloud-sync file
# ops are unaffected. Finder windows are restored on relaunch (macOS default).
{ config, lib, ... }:

let
  cfg = config.hn.serviceStationReload;

  reloadScript = ''
    for vol in ${lib.escapeShellArgs cfg.volumes}; do
      [ -d "$vol" ] || continue
      /usr/bin/pluginkit -e ignore -i ${lib.escapeShellArg cfg.extensionId} 2>/dev/null
      /usr/bin/pluginkit -e use   -i ${lib.escapeShellArg cfg.extensionId} 2>/dev/null
      ${lib.optionalString cfg.restartFinder "/usr/bin/killall Finder 2>/dev/null || true"}
    done
  '';
in
lib.mkIf cfg.enable {
  launchd.agents.service-station-reload = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        reloadScript
      ];
      WatchPaths = cfg.volumes;
      RunAtLoad = false;
      ProcessType = "Background";
    };
  };
}
