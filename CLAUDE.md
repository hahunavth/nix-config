@AGENTS.md

## Architecture Diagram

```mermaid
flowchart TD
	A[flake.nix<br/>global identity + host list] --> D["darwinConfigurations.&lt;hostname&gt; = mkDarwin ./hosts/macbook"]
	A --> E["nixosConfigurations.&lt;name&gt; = mkNixos ./hosts/&lt;name&gt;"]

	D --> W[hosts/macbook/<br/>default.nix + home.nix<br/>owns casks, hostname, features]
	E --> NX[hosts/&lt;name&gt;/<br/>default.nix + home.nix<br/>owns hardware, desktop, features]

	W --> PD[modules/darwin<br/>macOS platform base]
	NX --> PN[modules/nixos<br/>NixOS platform base]
	W --> SH[modules/home-shared<br/>cross-platform home core]
	NX --> SH
	PD --> BREW[modules/darwin/homebrew base]
```

Layers: **hosts/&lt;name&gt;/** — each machine OWNS its config (system `default.nix` +
`home.nix`); **lib/** — the `mkDarwin`/`mkNixos` builders; **modules/** — the reusable
layers a host pulls in (`home-shared` = cross-platform home; `darwin`/`nixos` = platform
system + `…/home/`). Identity (the single user) is global in `flake.nix`, threaded as
`userConfig`.

## Where does X go?

```mermaid
flowchart TD
	Q{What am I adding?}
	Q -->|New machine| M[hosts/&lt;name&gt;/ default.nix + home.nix, then list it in flake.nix]
	Q -->|GUI app| G[cask base in modules/darwin/homebrew/casks/*.nix<br/>or homebrew.casks in hosts/&lt;name&gt;/default.nix]
	Q -->|CLI tool| C[modules/home-shared/packages/*.nix]
	Q -->|Shell alias| A[modules/home-shared/aliases/*.nix]
	Q -->|Program config| P[modules/home-shared/programs/&lt;program&gt;.nix]
	Q -->|Feature toggle| F[hn.* in hosts/&lt;name&gt;/home.nix]
	Q -->|System setting| S[a modules/darwin/ module, or hosts/&lt;name&gt;/default.nix]
	Q -->|Language runtime| R[mise globalConfig, or per-project .mise.toml]
	Q -->|Secret / key| K[secrets/*.sops.yaml via sops-nix]
```

Nested `AGENTS.md` files document the non-obvious directories: `hosts/` (each host
owns its config), `lib/`, `pkgs/`, `modules/nixos/orbstack/` (generated — do not
edit), `modules/home-shared/programs/` (the Atlassian trio), and `modules/darwin/homebrew/`.
Read the one next to the files you're editing.