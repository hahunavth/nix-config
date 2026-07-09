{ pkgs, lib, ... }:

{
  # defaultbrowser CLI, also handy for re-running manually
  home.packages = [ pkgs.defaultbrowser ];

  # Set Arc as the default browser.
  # The default browser is a per-user LaunchServices setting, so this runs in
  # the home-manager activation (as the user), not the system activation.
  # Arc's short name in `defaultbrowser` is "browser" (from its bundle id
  # company.thebrowser.Browser).
  # NOTE: macOS security shows a one-time confirmation dialog that must be
  # approved in the GUI; there is no fully silent way to change the browser.
  home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -e "/Applications/Arc.app" ]; then
      $DRY_RUN_CMD ${pkgs.defaultbrowser}/bin/defaultbrowser browser || true
    fi
  '';
}
