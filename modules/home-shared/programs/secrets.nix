# Secrets via sops-nix (age-encrypted). SCAFFOLD — inert until a host opts in.
#
# The sops home-manager module is always loaded (see lib/mk-system.nix
# `sharedModules`), but this module only configures it when
# `hn.secrets.enable` is true. That flag defaults to false because sops needs a
# private age key present on the machine at ~/.config/sops/age/keys.txt, which
# is placed manually (never committed). See docs/runbooks/secrets.md.
#
# To turn it on for a host:
#   1. Generate a key and add its PUBLIC recipient to secrets/.sops.yaml.
#   2. Create + encrypt secrets/secrets.yaml (`sops secrets/secrets.yaml`).
#   3. Set `features.secrets = true;` in the host's hosts/<host>.nix.
#   4. Uncomment the secret entries below for the material you store.
{ config, lib, ... }:
let
  cfg = config.hn.secrets;
  home = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.enable {
    sops = {
      # Private key used to decrypt. Placed manually, outside nix/git.
      age.keyFile = "${home}/.config/sops/age/keys.txt";

      # Default encrypted store. Individual secrets can override with `sopsFile`.
      defaultSopsFile = ../../../secrets/secrets.yaml;

      # Example: migrate the on-disk SSH keys referenced by ssh.nix here, so a
      # fresh machine needs only the age key instead of hand-copied key files.
      # secrets = {
      #   "ssh/kod-work" = {
      #     path = "${home}/.ssh/kod-work.pem";
      #     mode = "0600";
      #   };
      #   "ssh/hahunavth" = {
      #     path = "${home}/.ssh/hahunavth";
      #     mode = "0600";
      #   };
      # };
    };
  };
}
