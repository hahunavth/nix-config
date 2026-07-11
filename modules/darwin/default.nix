# macOS system entry point: shared nix-darwin modules plus Homebrew wiring.
{
  imports = [
    ./configuration.nix
    ./nix-settings.nix
    ./misc-system.nix
    ./security.nix
    ./linux-builder.nix
    ./fonts.nix
    ./macos-defaults.nix
    ./raycast-beta.nix
    ./homebrew
  ];
}
