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

      # Per-host config (migrated from the old machine's ~/.ssh/config backup).
      # NOTE: the referenced key files (kod-work.pem, hahunavth,
      # hahunavth-Bitbucket, hahunavth_claude) are not managed by nix —
      # copy them over from the old machine and chmod 600 them.
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

      # Merged from the two bitbucket.org blocks in the backup (a manual one
      # plus a Sourcetree-generated one). IdentityFile is additive in OpenSSH,
      # so both keys are offered. AddKeysToAgent/UseKeychain come from "*".
      "bitbucket.org" = {
        User = "hahunavth";
        PreferredAuthentications = "publickey";
        IdentityFile = [
          "~/.ssh/hahunavth"
          "~/.ssh/hahunavth-Bitbucket"
        ];
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/hahunavth";
        IdentitiesOnly = "yes";
      };

      # Homelab box over Tailscale. ControlMaster reuses one shared connection
      # so many quick `ssh` calls don't each open a session and trip the remote
      # sshd MaxStartups rate-limit. First call opens the master; later calls
      # ride it for 10 min.
      "homelab-tailscale" = {
        HostName = "100.110.190.53";
        User = "kod_admin";
        IdentityFile = "~/.ssh/hahunavth";
        IdentitiesOnly = "yes";
        TCPKeepAlive = "yes";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%r@%h-%p";
        ControlPersist = "10m";
        ServerAliveInterval = 30;
        ServerAliveCountMax = 4;
      };

      "homelab-tailscale-claude" = {
        HostName = "100.110.190.53";
        Port = 2223;
        User = "kod_admin";
        IdentityFile = "~/.ssh/hahunavth_claude";
        IdentitiesOnly = "yes";
        PreferredAuthentications = "publickey";
        PasswordAuthentication = "no";
        TCPKeepAlive = "yes";
      };

      "homelab-tailscale-wsl" = {
        HostName = "100.110.190.53";
        User = "kod_admin";
        IdentityFile = "~/.ssh/hahunavth";
        IdentitiesOnly = "yes";
        TCPKeepAlive = "yes";
        RemoteCommand = "wsl bash -l";
        RequestTTY = "yes";
      };

      "jira_search" = {
        HostName = "192.168.120.33";
        User = "Kodnet";
        PasswordAuthentication = "yes";
      };
    };
  };
}
