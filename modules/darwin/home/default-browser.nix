{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.hn.defaultBrowser;
in
lib.mkIf cfg.enable {
  # defaultbrowser CLI, also handy for re-running manually (run it with no
  # arguments to list the handler short names it accepts).
  home.packages = [ pkgs.defaultbrowser ];

  # Set the default browser (Arc by default; hn.hammerspoon.urlRouter points this
  # at Hammerspoon instead, so links can be dispatched per host).
  # The default browser is a per-user LaunchServices setting, so this runs in
  # the home-manager activation (as the user), not the system activation.
  # NOTE: macOS security shows a one-time confirmation dialog that must be
  # approved in the GUI; there is no fully silent way to change the browser.
  home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -e ${lib.escapeShellArg cfg.app} ]; then
      $DRY_RUN_CMD ${pkgs.defaultbrowser}/bin/defaultbrowser ${lib.escapeShellArg cfg.handler} || true
    fi
  '';
}
