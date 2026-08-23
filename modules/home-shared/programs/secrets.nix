# Secrets via sops-nix (age-encrypted). SCAFFOLD — configures nothing yet.
#
# The sops home-manager module is loaded on every host (lib/mk-system.nix
# `sharedModules`); this file is what would actually use it, and it stays inert
# until hn.secrets.enable.
#
# Off by default for a reason that no amount of nix can fix: decryption needs a
# private age key already on the machine at ~/.config/sops/age/keys.txt. That
# key cannot be committed, so enabling this on a machine that lacks it turns
# every rebuild into a failure. Setting up the key is a manual, per-machine
# step — docs/runbooks/secrets.md.
#
# The target this exists for is ./ssh.nix, whose private keys are currently
# hand-copied files; moving them here is what would make a fresh machine need
# only the one age key.
#
# To turn it on for a host:
#   1. Generate a key and add its PUBLIC recipient to secrets/.sops.yaml.
#   2. Create + encrypt secrets/secrets.yaml (`sops secrets/secrets.yaml`).
#   3. Set `hn.secrets.enable = true;` in the host's hosts/<name>/home.nix.
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
