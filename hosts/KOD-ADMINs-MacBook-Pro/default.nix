{ hostname, ... }:

{
  imports = [ ../../modules/darwin ];

  networking.hostName = hostname;

  # ターゲットプラットフォーム
  nixpkgs.hostPlatform = "aarch64-darwin";
}
