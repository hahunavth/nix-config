# Maven — DELIBERATELY A NO-OP. This module sets nothing; it exists to record
# the two decisions below so they are not re-litigated, and to hold the
# MAVEN_OPTS escape hatch ready to uncomment.
#
# Maven itself comes from the Atlassian SDK (atlas-mvn) or from
# `nix develop .#atlassian`, which sets MAVEN_OPTS in the shell instead.
#
# NOTE: re-add `config` to the lambda pattern if the MAVEN_OPTS line below is
# ever uncommented (it references config.home.homeDirectory).
{ ... }:

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
  # home.sessionVariables.MAVEN_OPTS = "-Dmaven.repo.local=${config.home.homeDirectory}/.m2/repository -Dmaven.artifact.threads=16";
}
