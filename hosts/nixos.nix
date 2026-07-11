{
  username = "kod_admin";
  hostname = "nixos";
  # Profile is unused on Linux (Homebrew-only) but still validated.
  profile = "personal";
  system = "aarch64-linux";
  # This is a KOD dev VM: keep the Atlassian SDK tooling that the "personal"
  # profile would otherwise omit. (hammerspoon/defaultBrowser/winTunnel are
  # macOS-only and stay off here automatically.)
  features = {
    atlassian = true;
  };
}
