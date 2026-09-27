# Where does X go?

Each leaf below names the file to create or edit, plus the second file you have to wire it into.
The circled numbers are the layers from [architecture.md](architecture.md#layers).

```mermaid
flowchart LR
  Q{"What are you<br/>adding?"}

  Q --> A1["<b>GUI app</b>"]
  A1 --> A1p["① <code>modules/darwin/homebrew/casks/{apps,development,system}.nix</code> — every Mac<br/>④ <code>homebrew.casks</code> in <code>hosts/&lt;name&gt;/default.nix</code> — one Mac<br/><b>never nixpkgs for GUI apps</b>"]

  Q --> A2["<b>CLI tool</b>"]
  A2 --> A2p["② <code>modules/home-shared/packages/{development,system}.nix</code><br/><i>already imported — nothing else to wire</i>"]

  Q --> A3["<b>Shell alias</b>"]
  A3 --> A3p["② <code>modules/home-shared/aliases/&lt;domain&gt;.nix</code><br/>merge it in <code>aliases/default.nix</code>"]

  Q --> A4["<b>Program config</b>"]
  A4 --> A4p["② <code>modules/home-shared/programs/&lt;program&gt;.nix</code><br/>import it in <code>modules/home-shared/default.nix</code>"]

  Q --> A5["<b>macOS-only<br/>home behaviour</b>"]
  A5 --> A5p["③ <code>modules/darwin/home/&lt;name&gt;.nix</code><br/>import it in <code>modules/darwin/home/default.nix</code>"]

  Q --> A6["<b>Optional feature</b><br/>on for some hosts"]
  A6 --> A6p["② declare <code>hn.&lt;f&gt;</code> in <code>modules/home-shared/features.nix</code><br/>gate the module with <code>lib.mkIf config.hn.&lt;f&gt;.enable</code><br/>④ enable it in <code>hosts/&lt;name&gt;/home.nix</code>"]

  Q --> A7["<b>System setting</b>"]
  A7 --> A7p["① a module in <code>modules/darwin/</code> — every Mac<br/>④ <code>hosts/&lt;name&gt;/default.nix</code> — one Mac<br/>no typed option? <code>system.defaults.CustomUserPreferences.&quot;&lt;domain&gt;&quot;</code>"]

  Q --> A8["<b>Language runtime</b>"]
  A8 --> A8p["② mise — <code>globalConfig</code> in <code>programs/mise.nix</code><br/>or a per-project <code>.mise.toml</code><br/><b>not nix, not homebrew</b>"]

  Q --> A9["<b>Secret / key</b>"]
  A9 --> A9p["<code>secrets/*.sops.yaml</code> via sops-nix<br/>inert until a host sets <code>hn.secrets.enable</code>"]

  Q --> A10["<b>Custom package</b>"]
  A10 --> A10p["<code>pkgs/&lt;name&gt;/default.nix</code><br/>export it in <code>pkgs/default.nix</code><br/><i>lands in flake packages AND checks</i>"]

  Q --> A11["<b>Dev shell</b>"]
  A11 --> A11p["<code>shells/&lt;name&gt;.nix</code><br/>add <code>&lt;name&gt; = importShell &quot;&lt;name&gt;&quot;;</code> to <code>devShells</code> in <code>flake.nix</code>"]

  Q --> A12["<b>New machine</b>"]
  A12 --> A12p["④ <code>hosts/&lt;name&gt;/{default.nix,home.nix}</code><br/>list it in <code>flake.nix</code><br/><i>see docs/runbooks/add-a-host.md</i>"]

  classDef q fill:#f1f5f9,stroke:#475569,stroke-width:2px,color:#0f172a
  classDef k fill:#ffffff,stroke:#94a3b8,color:#0f172a
  classDef l1 fill:#fef3c7,stroke:#d97706,color:#451a03
  classDef l2 fill:#ccfbf1,stroke:#0d9488,color:#042f2e
  classDef l3 fill:#ffe4e6,stroke:#e11d48,color:#4c0519
  classDef l0 fill:#eef2ff,stroke:#6366f1,color:#1e1b4b
  class Q q
  class A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12 k
  class A1p,A7p l1
  class A2p,A3p,A4p,A5p,A6p,A8p l2
  class A12p l3
  class A9p,A10p,A11p l0
```

Step-by-step versions: [add a package](runbooks/add-a-package.md), [add a host](runbooks/add-a-host.md),
[add a NixOS host](runbooks/add-nixos-host.md), [secrets](runbooks/secrets.md).

## Feature registry (`hn.*`)

Options are declared in [`modules/home-shared/features.nix`](../modules/home-shared/features.nix),
and a host opts in from its own `hosts/<name>/home.nix`. Consuming modules are gated with
`lib.mkIf config.hn.<f>.enable`, so a feature that's off adds nothing to the closure.

| option | default | what it turns on |
|---|---|---|
| `hn.hammerspoon` | on (macOS) | Lua automation; sub-toggles are declared in `features.nix` |
| `hn.defaultBrowser` | on (macOS) | sets the per-user http/https handler on activation |
| `hn.atlassian` | off | Atlassian Plugin SDK + branch-based mise/Java switching |
| `hn.homelabTunnel` | off | socat port-forward aliases to the homelab over Tailscale |
| `hn.remoteDocker` | off | Docker CLI with no local engine, plus remote contexts over SSH |
| `hn.staleCwdRecovery` | off | repairs a shell whose cwd vanished when a volume was unplugged |
| `hn.secrets` | off | sops-nix age-encrypted secrets |
| `hn.atuin` | off | Atuin shell history (Ctrl-R search, optional sync) |

Adding one takes three steps:

1. Declare the option in `features.nix`.
2. Gate the module with `lib.mkIf config.hn.<f>.enable`.
3. Enable it in the host: `hn.<f>.enable = true;`.

Outside `hn.*`: `nix.linux-builder` is on by default on darwin
([`modules/darwin/linux-builder.nix`](../modules/darwin/linux-builder.nix)), and `hosts/macbook`
turns it off.
