# Docker CLI pointed at a REMOTE engine over SSH — no local daemon.
#
# `DOCKER_HOST=ssh://<host>` makes the local CLI run `ssh <host> docker system
# dial-stdio` and tunnel the Docker API over that stdio pipe. Nothing listens on
# the network, so over Tailscale the only exposed surface is the remote sshd —
# no `tcp://…:2375` to firewall, no TLS certs to manage.
#
# Contexts are the switchable form of the same thing. Docker stores each one as
# ~/.docker/contexts/meta/<sha256(name)>/meta.json, so they are declared here
# instead of by hand with `docker context create`. The *selected* context lives
# in ~/.docker/config.json, which stays unmanaged so `docker context use` keeps
# working (and so docker can keep rewriting that file).
#
# Precedence, highest first: `docker --context <n>` > $DOCKER_HOST >
# $DOCKER_CONTEXT > the context selected in config.json > `default` (local
# socket). Setting $DOCKER_HOST globally is therefore a sledgehammer — it wins
# over everything and makes every local docker use (OrbStack, testcontainers,
# devcontainers) silently target the remote box, and every command hang when the
# remote is asleep. hn.remoteDocker.defaultContext is the softer opt-in.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hn.remoteDocker;

  # name -> ~/.docker/contexts/meta/<sha256(name)>/meta.json (docker's own layout)
  contextFile = name: host: {
    name = ".docker/contexts/meta/${builtins.hashString "sha256" name}/meta.json";
    value.text = builtins.toJSON {
      Name = name;
      Metadata.Description = "declared in nix-darwin (hn.remoteDocker)";
      Endpoints.docker = {
        Host = host;
        SkipTLSVerify = false;
      };
    };
  };

  # `dk-<context> ps` runs one command against that engine, whatever the current
  # context is. Derived from the options, hence here and not in aliases/.
  contextAliases = lib.mapAttrs' (name: _: {
    name = "dk-${name}";
    value = "docker --context ${name}";
  }) cfg.contexts;
in
lib.mkIf cfg.enable {
  # docker-client is the CLI only (no dockerd — it wouldn't run on darwin
  # anyway); the compose and buildx plugins come with it, so `docker compose`
  # and `docker buildx` work against the remote engine.
  home.packages = [ pkgs.docker-client ];

  home.file = lib.mapAttrs' contextFile cfg.contexts;

  programs.zsh.shellAliases = {
    dctx = "docker context use"; # dctx homelab / dctx default
    dctxls = "docker context ls";
  }
  // contextAliases;

  # Opt-in global default. DOCKER_CONTEXT rather than DOCKER_HOST: `--context`
  # and a per-project DOCKER_HOST (direnv) still override it, and
  # `docker context ls` keeps showing the truth.
  home.sessionVariables = lib.mkIf (cfg.defaultContext != null) {
    DOCKER_CONTEXT = cfg.defaultContext;
  };
}
