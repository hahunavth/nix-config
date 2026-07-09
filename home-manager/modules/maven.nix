{ config, ... }:

{
  # Maven download/behavior tuning (applies to mvn and atlas-mvn alike).
  #
  # - maven.repo.local: one shared writable repo. Also required for the
  #   Atlassian SDK 9.1.1, which lives in the read-only nix store and would
  #   otherwise try to write inside its own directory.
  # - maven.artifact.threads: parallel dependency downloads (default is 5).
  #
  # NOTE (measured 2026-07): from this machine the default Maven Central CDN
  # (repo.maven.apache.org, Fastly) is FASTER than the Google Cloud mirrors
  # (~347 vs ~200-253 KB/s), so no <mirror> is configured on purpose.
  home.sessionVariables.MAVEN_OPTS =
    "-Dmaven.repo.local=${config.home.homeDirectory}/.m2/repository -Dmaven.artifact.threads=16";
}
