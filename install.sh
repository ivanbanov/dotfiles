#!/usr/bin/env bash
# Bootstrap a fresh macOS machine from this dotfiles repo.
#
#   git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./install.sh
#
# Idempotent: safe to re-run. It will NOT overwrite an existing
# ~/.config/secrets.env, and it stows packages with GNU Stow.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

# 1. Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon default prefix
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed."
fi

# 2. Packages ---------------------------------------------------------------
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3. oh-my-zsh + plugins (not brew-managed) ---------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 4. tmux plugin manager ----------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
[ -d "$TPM_DIR" ] || git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

# 5. Secrets scaffold -------------------------------------------------------
if [ ! -f "$HOME/.config/secrets.env" ]; then
  mkdir -p "$HOME/.config"
  cp "$DOTFILES_DIR/secrets/.config/secrets.env.example" "$HOME/.config/secrets.env"
  warn "Created ~/.config/secrets.env from template — FILL IN your tokens."
fi

# 6. Stow all packages ------------------------------------------------------
PACKAGES=(zsh git tmux hammerspoon config)
info "Stowing: ${PACKAGES[*]}"
for pkg in "${PACKAGES[@]}"; do
  # --adopt would pull existing files into the repo; we prefer to fail loudly
  # on conflicts so nothing is silently overwritten. Back up & remove clashes
  # yourself, then re-run, or use:  stow --adopt <pkg>  (then git diff to review).
  stow --target="$HOME" --restow "$pkg"
done

# NOTE: secrets is intentionally NOT stowed — the real secrets.env lives
# outside git (created in step 5); only the .example template is tracked.

info "Done. Restart your shell:  exec zsh"
info "Remember to fill in ~/.config/secrets.env and set the WakaTime key in Zed."
