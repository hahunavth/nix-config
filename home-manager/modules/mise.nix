{ ... }:

{
  # Runtime version manager. Global defaults are below; per-project versions
  # live in each repo's .mise.toml (see CLAUDE.md, incl. the Atlassian SDK pairing).
  # Tool versions resolve at `mise install` time (network), not at nix build time.
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      settings = {
        # Implicitly trust mise configs under the work-repos root, so the
        # atlas-mise-generated .mise.local.toml never hits the trust prompt
        # (trust is stored per-path and breaks on renames/moves otherwise).
        trusted_config_paths = [ "/Volumes/ext_ssd" ];
      };

      tools = {
        node = "lts";
        pnpm = "11";
        # All three JDKs are installed; the first is the global default.
        # Atlassian plugin projects pin the matching version in their .mise.toml.
        # Java 8 uses Zulu — Temurin has no arm64 JDK 8 for Apple Silicon.
        java = [
          "temurin-25"
          "temurin-17"
          "zulu-8"
        ];
      };
    };
  };
}
