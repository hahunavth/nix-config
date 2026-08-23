# Sets the default http/https handler — the "default browser".
#
# This is a per-USER LaunchServices setting, not a system one, which is why it
# runs in the home-manager activation rather than anywhere in modules/darwin.
#
# It cannot be made fully declarative: macOS shows a confirmation dialog that
# has to be clicked, once, in the GUI. Expect it on the first switch and after
# any change to `handler`.
#
# The interesting consumer is hn.hammerspoon.urlRouter, which points `handler`
# at Hammerspoon so links can be dispatched per hostname instead of all going
# to one browser.
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
  # Also kept on PATH for interactive use: run `defaultbrowser` with no
  # arguments to list the SHORT NAMES it accepts, which is the only way to find
  # the right value for `handler` (they are not bundle ids).
  home.packages = [ pkgs.defaultbrowser ];

  # Guarded on the app existing, so a fresh machine whose casks have not
  # installed yet does not get pointed at a browser that is not there. `|| true`
  # for the same reason in the other direction: a refused or dismissed dialog
  # must not fail the whole activation.
  home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -e ${lib.escapeShellArg cfg.app} ]; then
      $DRY_RUN_CMD ${pkgs.defaultbrowser}/bin/defaultbrowser ${lib.escapeShellArg cfg.handler} || true
    fi
  '';
}
