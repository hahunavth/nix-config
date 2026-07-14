# secrets/

Age-encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix).

- **`.sops.yaml`** — creation rules: which age recipients may decrypt. Commit this.
- **`secrets.yaml`** — the encrypted store (you create it). Its *ciphertext* is
  safe to commit; the plaintext never leaves your editor / the nix store.
- The **private** age key lives at `~/.config/sops/age/keys.txt` — **never** here,
  never in git.

This is a scaffold: nothing is wired to real secrets yet. The consuming module
[`../modules/home-shared/programs/secrets.nix`](../modules/home-shared/programs/secrets.nix)
stays inert until a host sets `features.secrets = true`. Full steps:
[`../docs/runbooks/secrets.md`](../docs/runbooks/secrets.md).
