# Work Mac — host-specific home config (on top of the shared core).
# Feature toggles this machine wants; hammerspoon/defaultBrowser default on for
# macOS (see modules/home-shared/features.nix). Add host-only user packages here too.
{ ... }:

{
  hn.atlassian.enable = true; # Atlassian Plugin SDK + branch-based mise switching
  hn.homelabTunnel.enable = true; # socat port-forwards to the homelab (hl-* aliases)

  hn.hammerspoon = {
    # Announce the external SSD coming and going — the replug is otherwise
    # silent, and it's the event hn.staleCwdRecovery below is recovering from.
    #
    # onMount also re-binds Service Station's Finder extension: its sandbox
    # bookmark is tied to a mount *instance*, so after a replug the right-click
    # menu silently stops appearing on the volume. Killing the app doesn't help
    # — the menu is drawn by a Finder Sync extension hosted by PlugInKit, not by
    # the app process. The Finder relaunch is what makes it re-spawn against the
    # new mount; it also aborts any in-progress *Finder* copy (terminal and app
    # file ops are unaffected), so drop that line if you'd rather not risk it.
    volumeWatch = {
      enable = true;
      volumes = [ "/Volumes/ext_ssd" ];
      onMount = ''
        /usr/bin/pluginkit -e ignore -i com.knurling.ServiceStation.FinderSync
        /usr/bin/pluginkit -e use   -i com.knurling.ServiceStation.FinderSync
        /usr/bin/killall Finder
      '';
    };

    # Hammerspoon becomes the system http/https handler and forwards each link:
    # loopback to Chrome (its devtools/profiles are the dev browser), everything
    # else to Arc. Approve the macOS "change default browser" prompt on the next
    # switch, and note links then depend on Hammerspoon running.
    urlRouter = {
      enable = true;
      fallback = "company.thebrowser.Browser"; # Arc
      rules = [
        {
          hosts = [
            "^localhost$"
            "%.localhost$"
            "^127%."
            "^0%.0%.0%.0$"
            "^::1$"
            "^%[::1%]$"
          ];
          bundleId = "com.google.Chrome";
        }
      ];
    };
  };

  # Docker CLI with no local engine: the homelab (Windows box, Docker Desktop) is
  # reached over Tailscale through the `homelab-tailscale` ssh host, and is the
  # default target. Switch a single shell with `dctx default`, one command with
  # `docker --context default`, or a project with DOCKER_HOST in .envrc.
  hn.remoteDocker = {
    enable = true;
    contexts.homelab = "ssh://homelab-tailscale";
    defaultContext = "homelab";
  };

  # Replugging the external SSD leaves every shell that was sitting on it with an
  # unusable working directory; a chdir is the only repair (see the module).
  hn.staleCwdRecovery = {
    enable = true;
    volumes = [ "/Volumes/ext_ssd" ];
  };
}
