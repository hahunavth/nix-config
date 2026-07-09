#!/usr/bin/env bash
# Bootstrap a fresh macOS machine to this nix-darwin config.
#
# Prerequisite: this repo is already present at /etc/nix-darwin, e.g.
#   sudo mkdir -p /etc/nix-darwin && sudo chown "$USER" /etc/nix-darwin
#   git clone <repo-url> /etc/nix-darwin
# (nix-darwin can manage Homebrew casks but cannot install Homebrew or Nix
# itself — that is what this script does.)
set -euo pipefail

REPO="/etc/nix-darwin"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

step "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the Xcode CLT install dialog, then re-run this script."
  exit 1
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# put brew on PATH for this session (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

step "Nix (Determinate Systems installer — flakes enabled by default)"
if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # load nix into this session
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || true
fi

step "Ensure the repo is git-tracked (flakes ignore untracked files)"
git -C "$REPO" add -A || true

step "First darwin-rebuild (bootstraps nix-darwin, selects by hostname)"
sudo nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch --flake "$REPO"

step "Done"
cat <<EOF
Future rebuilds: run 'rebuild' (alias) or:
  sudo darwin-rebuild switch --flake $REPO

Manual one-time steps that can't be declared in nix:
  - Approve GUI permission prompts (Arc default browser, Input Source Pro
    Accessibility, App Management).
  - Set your terminal font to a Nerd Font (JetBrainsMono/FiraCode Nerd Font).
  - Enable the Bitwarden SSH agent if you use it (Bitwarden → Settings).
  - Fix keyboard type (ANSI/ISO/JIS) via the Keyboard Setup Assistant if needed.
See docs/onboarding.md for the full checklist.
EOF
