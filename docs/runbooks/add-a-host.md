# Runbook: add a host

1. **Create the host file** under `hosts/`, e.g. `hosts/personal.nix`:

   ```nix
   {
     username = "you";
     hostname = "Your-MBP";      # must be unique, [a-zA-Z0-9-]
     profile = "personal";        # personal | work
     system = "aarch64-darwin";   # optional; default aarch64-darwin
     # features = { hammerspoon = true; };  # Phase 1+, optional
   }
   ```

   Shared identity (`fullName`, `githubUsername`, `email`, `workEmail`) comes from
   `hosts/common.nix` — only override per-host if it differs.

2. **Register it** in `hosts/default.nix`:

   ```nix
   hosts = {
     work = import ./work;
     nixos = import ./nixos;
     personal = import ./personal.nix;   # <-- add
   };
   ```

3. **`git add -A`** — flakes only see git-tracked files.

4. **Verify** it evaluates and builds:

   ```bash
   nix build .#darwinConfigurations.Your-MBP.system            # macOS
   nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run  # Linux
   ```

`lib/hosts.nix` validates the entry (required attrs, hostname format/uniqueness,
profile & system whitelists). `darwin-rebuild` auto-selects the entry matching the
machine's hostname.
