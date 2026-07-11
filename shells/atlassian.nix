# Ad-hoc Atlassian-plugin shell: `nix develop .#atlassian`.
#
# Complements (does not replace) the per-project mise + atlas-mise workflow —
# use this for a quick reproducible Maven/JDK entry when you don't want to set up
# .mise.toml. For real plugin repos prefer `atlas-mise-enable` (branch-based JDK
# + SDK switching). The SDK binaries come from ~/.local/share/atlassian-plugin-sdk
# (installed by home-manager), not from this shell.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    maven
    temurin-bin-17 # JDK 17 (pair with SDK 9.1.1); use mise for JDK 8 projects
  ];
  # Keep Maven's local repo writable (the SDK lives in the read-only nix store).
  MAVEN_OPTS = "-Dmaven.repo.local=$HOME/.m2/repository -Dmaven.artifact.threads=16";
}
