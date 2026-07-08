{ hostname, ... }:

{
  imports = [ ../../modules/darwin ];

  networking.hostName = hostname;

  # Target platform
  nixpkgs.hostPlatform = "aarch64-darwin";
}
