{
  pkgs,
  lib,
  ...
}:

{
  programs.ssh = {
    enable = true;
    # Set things explicitly instead of relying on defaults
    enableDefaultConfig = false;

    # Lets `ssh orb` reach OrbStack Linux VMs/containers (macOS-side path).
    # (must be included before any Host block)
    includes = lib.optionals pkgs.stdenv.isDarwin [ "~/.orbstack/ssh/config" ];

    settings = {
      "*" = {
        # Automatically add keys to ssh-agent on first use
        AddKeysToAgent = "yes";
        # Keep connections alive (keepalive every 60s)
        ServerAliveInterval = 60;
        # Use Bitwarden Desktop as the SSH agent (keys in the vault, unlocked by
        # Touch ID). Enable it in Bitwarden → Settings → "Enable SSH agent".
        # Hosts below that set IdentitiesOnly=yes keep using their on-disk keys.
        # NOTE (Linux): on the OrbStack VM ~ is /home/kod_admin, where this
        # socket does not exist (Bitwarden runs on the Mac, socket under
        # /Users/kod_admin). ssh tolerates a missing agent, but outbound auth to
        # hosts with IdentitiesOnly=yes (e.g. github.com) won't work from the VM
        # until an agent is wired up there — revisit if git push from the VM is
        # needed (OrbStack forwards the Mac ssh-agent; see forward_ssh_agent).
        IdentityAgent = "~/.bitwarden-ssh-agent.sock";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        # Store passphrases in the macOS Keychain. Apple-only OpenSSH option —
        # it's an unknown keyword on stock Linux OpenSSH and would error out.
        UseKeychain = "yes";
      };

      # Per-host config (migrated from the old machine's ~/.ssh/config backup).
      # Private keys for hahunavth / hahunavth_claude live in Bitwarden and are
      # served via the IdentityAgent above — do NOT put them on disk. ssh still
      # needs their public keys on disk to pick which agent identity to use with
      # IdentitiesOnly=yes; those .pub files are written declaratively below.
      # The on-disk private keys kod-work.pem and hahunavth-Bitbucket are NOT
      # managed by nix — copy them over and chmod 600 them.
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

  # Public keys for the Bitwarden-held identities. Public keys are not secret;
  # ssh reads them to select the matching key from the Bitwarden agent when a
  # host sets IdentitiesOnly=yes. The private halves stay in the vault.
  home.file = {
    ".ssh/hahunavth.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOENeobOHtVpV5+fH6NorHHYMYcljup3QysmEVBvpfiY vuthanhha.2001@gmail.com\n";
    ".ssh/hahunavth_claude.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBtT0wTKIEC6zWmA1mTIp8hBd0+VjAAoQuTyH+jR22o claude-code@mac\n";
  };
}
