@AGENTS.md

## Architecture Diagram

```mermaid
flowchart TD
	A[flake.nix] --> B[lib/hosts.nix]
	H[hosts/common.nix] --> K[hosts/default.nix]
	I[hosts/work.nix] --> K
	J[hosts/nixos.nix] --> K
	K --> B
	B --> C[validated userConfig list]
	C --> D[darwinConfigurations]
	C --> E[nixosConfigurations]

	D --> F[modules/darwin/default.nix]
	F --> F1[darwin system modules]
	D --> G[modules/darwin/home]
	G --> G1[modules/shared]
	G1 --> G2[cross-platform home modules]

	E --> L[modules/nixos/default.nix]
	L --> L1[nixos config plus OrbStack modules]
	E --> M[modules/nixos/home]
	M --> G1

	F1 --> N[modules/darwin/homebrew]
```

Three layers: **hosts/** = machine data, **lib/** = pure logic (validation +
builders), **modules/** = config building blocks split by scope (`shared` runs
everywhere; `darwin`/`nixos` add their platform's system + `…/home/` modules).

## Where does X go?

```mermaid
flowchart TD
	Q{What am I adding?}
	Q -->|New machine| M[hosts/&lt;name&gt;.nix + register in hosts/default.nix]
	Q -->|GUI app| G[cask in modules/darwin/homebrew/casks/*.nix<br/>or extraCasks in a profile]
	Q -->|CLI tool| C[modules/shared/packages/*.nix]
	Q -->|Shell alias| A[modules/shared/aliases/*.nix]
	Q -->|Program config| P[modules/shared/programs/&lt;program&gt;.nix]
	Q -->|System setting| S[a modules/darwin/ module, or<br/>system.defaults.CustomUserPreferences]
	Q -->|Language runtime| R[mise globalConfig, or per-project .mise.toml]
	Q -->|Secret / key| K[secrets/*.sops.yaml via sops-nix]
```

Nested `AGENTS.md` files document the non-obvious directories: `lib/`, `pkgs/`,
`modules/nixos/orbstack/` (generated — do not edit), `modules/shared/programs/` (the
Atlassian trio), and `modules/darwin/homebrew/`. Read the one next to the files
you're editing.