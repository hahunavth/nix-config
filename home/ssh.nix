{ ... }:

{
  programs.ssh = {
    enable = true;
    # Set things explicitly instead of relying on defaults
    enableDefaultConfig = false;

    # Lets `ssh orb` reach OrbStack Linux VMs/containers
    # (must be included before any Host block)
    includes = [ "~/.orbstack/ssh/config" ];

    settings = {
      "*" = {
        # Automatically add keys to ssh-agent on first use
        AddKeysToAgent = "yes";
        # Keep connections alive (keepalive every 60s)
        ServerAliveInterval = 60;
        # Store passphrases in the macOS Keychain
        UseKeychain = "yes";
      };

      # Per-host config (migrated from the old machine's ~/.ssh/config).
      # NOTE: the referenced key files (~/.ssh/kod-work.pem, ~/.ssh/hahunavth)
      # are not managed by nix — copy them over from the old machine.
      "192.168.120.33" = {
        HostName = "192.168.120.33";
        User = "kodnet";
      };

      "sise.dswikiworks.jp" = {
        HostName = "sise.dswikiworks.jp";
        User = "ubuntu";
        Port = 22;
        IdentityFile = "~/.ssh/kod-work.pem";
        IdentitiesOnly = "yes";
        TCPKeepAlive = "yes";
      };

      # AddKeysToAgent is set globally in settings."*" above
      "bitbucket.org".IdentityFile = "~/.ssh/hahunavth";

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/hahunavth";
        IdentitiesOnly = "yes";
      };
    };
  };
}
