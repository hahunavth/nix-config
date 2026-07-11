# Dev shell for editing THIS config repo. `nix develop` (or `.#default`).
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    nixfmt-rfc-style # formatter (`nix fmt`)
    statix # anti-pattern linter
    deadnix # dead-code finder
    nil # Nix LSP (editor completion)
  ];
}
