{ ... }:

{
  # Homebrew integration (for GUI apps not well-suited to nixpkgs)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";   # removes casks/formulae not listed here on rebuild
      extraFlags = [ "--verbose" ];   # shows real per-cask progress
    };

    # Note: the Atlassian Plugin SDK is NOT installed via Homebrew — its tap has
    # broken formula class names and the atlas-* binaries collide on link. Both
    # SDK versions are pinned via pkgs/atlassian-plugin-sdk + home/atlassian-sdk.nix.

    casks = [
      "claude"                 # Claude desktop app
      "slack"
      "arc"
      "google-chrome"
      "microsoft-edge"
      "visual-studio-code"
      "microsoft-office"       # Word, Excel, PowerPoint, OneNote
      "microsoft-teams"
      "remote-desktop-manager"
      "orbstack"               # Docker/Linux VMs (Docker Desktop alternative)
      "warp"                   # Warp terminal
      "sublime-text"
      "bitwarden"              # Bitwarden password manager
      "tailscale-app"          # Tailscale mesh VPN (GUI + menu-bar app)
      "input-source-pro"       # Auto-switch keyboard input source per app/site
      "obsidian"               # Obsidian notes / knowledge base
      "miniconda"              # Python / conda data-science stack
      "zoom"
      "syncthing-app"
      "iterm2"                 # Terminal emulator (alternative to Warp)
      "rectangle"              # Window snapping / management (half, quarter, full)
    ];
  };
}
