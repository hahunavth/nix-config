# Runbook: secrets (sops-nix)

Replaces "copy the SSH key files from the old machine" with a single age key.

Status: **scaffolded, not yet enabled.** The wiring exists (`sops-nix` input, the
`sops` home-manager module, `modules/shared/programs/secrets.nix`, `secrets/.sops.yaml`)
but `features.secrets` is off everywhere until you complete the steps below. This
is the one phase that needs a human — it requires your private key and your real
secret material.

## One-time per machine

1. **Generate an age key** (private key stays on the machine, out of git):

   ```bash
   mkdir -p ~/.config/sops/age
   nix run nixpkgs#age -- -keygen -o ~/.config/sops/age/keys.txt
   # print the PUBLIC recipient:
   nix run nixpkgs#age -- -keygen -y ~/.config/sops/age/keys.txt
   ```

2. **Register the public key** — paste it into `secrets/.sops.yaml` in place of
   `age1REPLACE_WITH_YOUR_AGE_PUBLIC_KEY`.

## Create the encrypted store

```bash
nix run nixpkgs#sops -- secrets/secrets.yaml
```

Add entries, e.g.:

```yaml
ssh:
  kod-work: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
```

## Enable it

1. Uncomment the matching `sops.secrets."…"` entries in
   `modules/shared/programs/secrets.nix`.
2. Import the module in `modules/shared/default.nix` (add `./programs/secrets.nix`).
3. Set `features.secrets = true;` in the host's `hosts/<name>.nix`.
4. `git add -A` (the encrypted `secrets.yaml` + `.sops.yaml`) and rebuild.

On activation sops-nix decrypts each secret to its declared `path` (e.g.
`~/.ssh/kod-work.pem`, mode `0600`). A fresh machine then needs only the age key.

## Notes

- Commit ciphertext only. The private key (`keys.txt`) is never committed.
- Secrets render to writable paths, not the read-only nix store.
- To rotate: re-`sops` the file; to add a machine, add its public key to
  `.sops.yaml` and `sops updatekeys secrets/secrets.yaml`.
