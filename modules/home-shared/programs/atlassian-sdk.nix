{
  config,
  lib,
  pkgs,
  ...
}:

# Atlassian Plugin SDK — both versions, at paths a project file can name.
#
# Installed from nix rather than Homebrew because Homebrew's Atlassian tap is
# broken in two ways at once: several versioned formulae have mismatched Ruby
# class names, and the atlas-* binaries collide on link so two versions cannot
# coexist. Two versions coexisting is exactly the requirement here.
#
# Both generations stay installed and a project picks one, because which SDK a
# repo needs follows from its branch and not from the machine. Pair 8.2.7 with
# Java 8 and 9.1.1 with Java 17; atlas-mise (./atlassian-mise.nix) does that
# automatically per branch.
let
  # Versions and hashes live in pkgs/, so they are also built by
  # `nix flake check` and a rotted upstream tarball fails in CI.
  customPkgs = import ../../../pkgs { inherit pkgs; };
in
lib.mkIf config.hn.atlassian.enable {
  # Symlinked to a fixed, version-numbered path. This is the whole point of the
  # module: a project's .mise.toml can put
  # ~/.local/share/atlassian-plugin-sdk/9.1.1/bin on PATH and stay valid across
  # rebuilds, whereas the /nix/store path underneath changes whenever the
  # derivation does.
  #
  # These are store symlinks, so the SDK tree is READ-ONLY — see maven.nix and
  # shells/atlassian.nix for the MAVEN_OPTS that keeps atlas-mvn from trying to
  # write into it.
  home.file.".local/share/atlassian-plugin-sdk/8.2.7".source = customPkgs.atlassian-plugin-sdk-8_2_7;
  home.file.".local/share/atlassian-plugin-sdk/9.1.1".source = customPkgs.atlassian-plugin-sdk-9_1_1;
}
