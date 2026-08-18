# Work Mac — host-specific home config (on top of the shared core).
# Feature toggles this machine wants; hammerspoon/defaultBrowser default on for
# macOS (see modules/home-shared/features.nix). Add host-only user packages here too.
{ ... }:

{
  hn.atlassian.enable = true; # Atlassian Plugin SDK + branch-based mise switching
  hn.winTunnel.enable = true; # socat port-forwards to the Windows box

  # Docker CLI with no local engine: the homelab (Windows box, Docker Desktop) is
  # reached over Tailscale through the `homelab-tailscale` ssh host, and is the
  # default target. Switch a single shell with `dctx default`, one command with
  # `docker --context default`, or a project with DOCKER_HOST in .envrc.
  hn.remoteDocker = {
    enable = true;
    contexts.homelab = "ssh://homelab-tailscale";
    defaultContext = "homelab";
  };

  # Reload Service Station's Finder extension when the external SSD remounts —
  # its sandbox bookmark goes stale on replug (see the module for the full why).
  hn.serviceStationReload = {
    enable = false;
    volumes = [ "/Volumes/ext_ssd" ];
  };

  # Replugging the external SSD leaves every shell that was sitting on it with an
  # unusable working directory; a chdir is the only repair (see the module).
  hn.staleCwdRecovery = {
    enable = true;
    volumes = [ "/Volumes/ext_ssd" ];
  };
}
