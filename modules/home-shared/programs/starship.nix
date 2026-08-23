# starship — the prompt, drawn as one contiguous powerline bar.
#
# Two things here are unusual enough to be worth reading before editing: glyphs
# are stored as hex codepoints and decoded (see `g` below), and the zone
# separators live in the top-level `format` rather than in each module (see the
# palette comment). Both exist for reasons that are not obvious from the result.
#
# Requires a Nerd Font in the TERMINAL's settings — a font in
# modules/darwin/fonts.nix is installed, not selected, so a terminal still set
# to a plain font renders every icon as a replacement box.
{ lib, ... }:

let
  # Nerd Font glyph from a hex codepoint. Glyphs MUST be written as codepoints
  # and decoded via fromJSON: literal private-use-area characters do not survive
  # the tooling that edits this file (they were silently stripped before, which
  # is why the prompt rendered as flat colored blocks with no separators).
  # Verified present in nerd-fonts.jetbrains-mono (modules/darwin/fonts.nix).
  #
  # A JSON \u escape is exactly 4 hex digits, so codepoints above U+FFFF — the
  # whole Material Design (md-*) set, which Nerd Fonts places at U+F0000+, i.e.
  # ~6900 of the font's ~11800 glyphs — have to be emitted as a UTF-16 surrogate
  # PAIR inside a single fromJSON call. Without the pair branch this failed
  # SILENTLY: `g "f150E"` decoded U+F150 and left a literal "E" in the prompt.
  g =
    cp:
    let
      n = lib.fromHexString cp;
      hex4 = v: lib.toLower (lib.fixedWidthString 4 "0" (lib.toHexString v));
      one = v: builtins.fromJSON ''"\u${hex4 v}"'';
      pair =
        v:
        let
          o = v - 65536;
        in
        builtins.fromJSON ''"\u${hex4 (55296 + (o / 1024))}\u${hex4 (56320 + (lib.mod o 1024))}"'';
    in
    if n <= 65535 then one n else pair n;

  sep = g "e0b0"; # hard right-pointing separator / tail (U+E0B0)

  icon = {
    git = g "e725"; # git branch
    node = g "e718"; # Node.js
    java = g "e738"; # Java
    python = g "e73c"; # Python
    package = g "f487"; # package
    docker = g "e7b0"; # Docker
    nix = g "f313"; # Nix snowflake
    conda = g "e715"; # dev-anaconda - conda environment
    lock = g "f023"; # read-only directory
  };

  # Powerline zone palette (256-color indices). The prompt is ONE contiguous bar
  # split into zones; each zone owns a background and the sep between two zones
  # is drawn with fg = previous zone's bg, bg = next zone's bg (the p10k look).
  #
  # The zone separators live in the top-level `format`, not in the modules: a
  # module's own format cannot know which module rendered before it, so putting
  # transitions there is the only way the color chain stays correct when
  # optional modules (git, languages) are absent. Cost: an empty zone collapses
  # to a 1-char gradient sliver instead of disappearing.
  dirBg = "24"; # cwd - dark blue
  gitBg = "54"; # git - purple
  envBg = "238"; # toolchains / env - dark grey, colored icons
  txt = "231"; # near-white text on the saturated zones
  dim = "252"; # softer text for versions on grey
in
{
  # starship prompt (automatically wired into zsh)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = lib.concatStrings [
        # No left cap: the bar starts flush at the left edge.
        "$directory"
        "[${sep}](fg:${dirBg} bg:${gitBg})" # cwd -> git
        "$git_branch$git_status"
        "[${sep}](fg:${gitBg} bg:${envBg})" # git -> env
        "$nodejs$java$python$conda$package"
        "\${custom.atlassian_sdk}"
        "$docker_context$nix_shell"
        "[${sep}](fg:${envBg})" # tail
        "$line_break$character"
      ];

      # Full working-directory path, no truncation.
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        read_only = " ${icon.lock}";
        format = "[ $path$read_only ](fg:${txt} bg:${dirBg})";
      };

      git_branch = {
        symbol = "${icon.git} ";
        format = "[ $symbol$branch ](fg:${txt} bg:${gitBg})";
      };
      # Conditional group: prints nothing (not even padding) on a clean repo.
      git_status.format = "([$all_status$ahead_behind ](fg:${txt} bg:${gitBg}))";

      # Toolchain zone. Each module contributes an icon in its language's own
      # colour plus a dim version string, all on the shared grey — so the eye
      # picks out which toolchains are active by hue, and reads versions only
      # when it wants them. All of these are conditional: starship prints
      # nothing for a language the current directory has no evidence of.
      nodejs = {
        symbol = "${icon.node} ";
        format = "[ $symbol](fg:114 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      java = {
        symbol = "${icon.java} ";
        format = "[ $symbol](fg:209 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      python = {
        symbol = "${icon.python} ";
        # Without this the module only triggers in directories that LOOK like a
        # Python project (.py, pyproject.toml, ...), so a venv activated and then
        # used anywhere else was invisible.
        detect_env_vars = [ "VIRTUAL_ENV" ];
        # \( \) are literal parens; the ( ) around them is starship's
        # conditional group, so a plain interpreter prints no empty "()".
        format = "[ $symbol](fg:117 bg:${envBg})[$version ](fg:${dim} bg:${envBg})[(\\($virtualenv\\) )](fg:${dim} bg:${envBg})";
      };

      # Conda environment. `base` stays hidden (ignore_base defaults true), so an
      # un-activated shell renders nothing.
      conda = {
        symbol = "${icon.conda} ";
        format = "[ $symbol](fg:149 bg:${envBg})[$environment ](fg:${dim} bg:${envBg})";
      };
      package = {
        symbol = "${icon.package} ";
        format = "[ $symbol](fg:180 bg:${envBg})[$version ](fg:${dim} bg:${envBg})";
      };
      docker_context = {
        symbol = "${icon.docker} ";
        format = "[ $symbol](fg:75 bg:${envBg})[$context ](fg:${dim} bg:${envBg})";
      };
      nix_shell = {
        symbol = "${icon.nix} ";
        format = "[ $symbol](fg:81 bg:${envBg})[$name ](fg:${dim} bg:${envBg})";
      };

      # Active Atlassian Plugin SDK version. There is no built-in module for
      # this, so it reads the .mise.local.toml that atlas-mise generates per
      # branch — which means the prompt shows the SDK the branch selected,
      # the thing that actually changes under you. `when` keeps the (forked)
      # command from running outside enabled plugin repos.
      custom.atlassian_sdk = {
        description = "Active Atlassian Plugin SDK version";
        detect_files = [ ".mise.local.toml" ];
        when = "grep -q atlassian-plugin-sdk .mise.local.toml";
        command = "grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' .mise.local.toml | head -1";
        shell = [
          "bash"
          "--noprofile"
          "--norc"
        ];
        symbol = "◆ ";
        format = "[ $symbol](fg:111 bg:${envBg})[$output ](fg:${dim} bg:${envBg})";
      };
    };
  };
}
