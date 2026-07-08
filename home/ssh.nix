{ ... }:

{
  programs.ssh = {
    enable = true;
    # Set things explicitly instead of relying on defaults
    enableDefaultConfig = false;

    # Lets `ssh orb` reach OrbStack Linux VMs/containers
    # (must be included before any Host block)
    includes = [ "~/.orbstack/ssh/config" ];

    settings."*" = {
      # Automatically add keys to ssh-agent on first use
      AddKeysToAgent = "yes";
      # Keep connections alive (keepalive every 60s)
      ServerAliveInterval = 60;
      # Store passphrases in the macOS Keychain
      UseKeychain = "yes";
    };
  };
}
