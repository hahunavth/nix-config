# Work Mac — host-specific home config (on top of the shared core).
# Feature toggles this machine wants; hammerspoon/defaultBrowser default on for
# macOS (see modules/shared/features.nix). Add host-only user packages here too.
{ ... }:

{
  hn.atlassian.enable = true; # Atlassian Plugin SDK + branch-based mise switching
  hn.winTunnel.enable = true; # socat port-forwards to the Windows box
}
