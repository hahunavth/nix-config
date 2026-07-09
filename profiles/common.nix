# Packages shared by every profile. Per-profile add/remove lives in
# profiles/<profile>.nix and is merged in modules/darwin/homebrew.nix.
{
  homebrew = {
    taps = [ ];
    brews = [ ];
    casks = [
      "claude" # Claude desktop app
      "claude-code@latest" # Claude Code CLI
      "arc"
      "google-chrome"
      "microsoft-edge"
      "visual-studio-code"
      "sublime-text"
      "orbstack" # Docker/Linux VMs (Docker Desktop alternative)
      "warp" # Warp terminal
      "iterm2" # Terminal emulator (alternative to Warp)
      "bitwarden" # Password manager
      "tailscale-app" # Tailscale mesh VPN (GUI + menu-bar app)
      "input-source-pro" # Auto-switch keyboard input source per app/site
      "obsidian" # Notes / knowledge base
      "miniconda" # Python / conda data-science stack
      "syncthing-app"
      "rectangle" # Window snapping / management
      "shottr" # Screenshot tool w/ annotation
    ];
    masApps = { };
  };
}
