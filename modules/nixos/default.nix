# Linux system entry point: OrbStack guest integration plus shared NixOS layer.
{
  imports = [
    ./orbstack/configuration.nix
    ./configuration.nix
  ];
}
