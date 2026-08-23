# Ad-hoc Atlassian-plugin shell: `nix develop .#atlassian`.
#
# NOT the normal path. A real plugin repo should run `atlas-mise-enable` once
# and let the branch pick its JDK + SDK (programs/atlassian-mise.nix); this
# shell is the escape hatch for a quick look at a repo you do not want to
# install hooks into.
#
# Only Maven and a JDK come from here. The atlas-* binaries themselves are
# installed by home-manager at ~/.local/share/atlassian-plugin-sdk/<version>
# (programs/atlassian-sdk.nix) and are on PATH independently of this shell.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    maven
    temurin-bin-17 # JDK 17 (pair with SDK 9.1.1); use mise for JDK 8 projects
  ];
  # Point the local repo at $HOME. The SDK is a nix store path, so an
  # atlas-mvn that defaults to writing inside its own directory fails on a
  # read-only filesystem.
  MAVEN_OPTS = "-Dmaven.repo.local=$HOME/.m2/repository -Dmaven.artifact.threads=16";
}
