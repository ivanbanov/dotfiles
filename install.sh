#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

# 0. Xcode Command Line Tools (provides git, cc, make — Homebrew needs them)
# ==================================================================================================
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools..."
  # Headless install: this magic file makes softwareupdate list the CLT package,
  # so we can install it without the GUI dialog.
  TRIGGER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  touch "$TRIGGER"
  LABEL="$(softwareupdate -l 2>/dev/null \
    | grep -B1 -E 'Command Line Tools' \
    | awk -F'* ' '/^ *\*/ {print $2}' | sed 's/^Label: //' | tail -n1)"
  if [ -n "$LABEL" ]; then
    softwareupdate -i "$LABEL" --verbose
  else
    # Fallback: trigger the GUI installer and wait for the user to finish it.
    xcode-select --install >/dev/null 2>&1 || true
    info "Finish the Command Line Tools install dialog, then press Return..."
    read -r _
  fi
  rm -f "$TRIGGER"
else
  info "Xcode Command Line Tools already installed."
fi

# 1. Homebrew
# ==================================================================================================
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon default prefix
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed."
fi

# 2. Packages
# ==================================================================================================
# Trust the third-party atlassian/acli tap (Homebrew 6+ gates untrusted taps;
# the trust list is local, so re-establish it here). Ignored on older brew.
brew trust --tap atlassian/acli >/dev/null 2>&1 || true
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# brew's nvm doesn't create its working dir, and nvm errors without it
mkdir -p "$HOME/.nvm"

# 3. oh-my-zsh + plugins
# ==================================================================================================
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

# 4. Claude Code
# ==================================================================================================
if ! command -v claude >/dev/null 2>&1; then
  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  info "Claude Code already installed."
fi

# 5. Protect local secrets
# ==================================================================================================
# These files are tracked (committed as templates) but hold real secrets once
# filled in. skip-worktree tells git to ignore local edits so they can't be
# committed. The flag is local-only, so it must be re-applied on every clone.
SECRET_FILES=(home/.npmrc home/.ssh/config)
info "Protecting secret files (git skip-worktree)..."
git update-index --skip-worktree "${SECRET_FILES[@]}"

# .gitconfig signs commits with an SSH key and verifies them against
# allowed_signers. Seed that file from the signing key so `git log
# --show-signature` trusts your own commits. Best-effort: the key is set up
# manually (never committed), so skip cleanly if it isn't there yet.
SIGNING_KEY="$HOME/.ssh/id_ed25519.pub"
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"
if [ -f "$SIGNING_KEY" ] && [ ! -f "$ALLOWED_SIGNERS" ]; then
  info "Seeding git allowed_signers..."
  EMAIL="$(git config --file "$DOTFILES_DIR/git/.gitconfig" user.email)"
  printf '%s namespaces="git" %s\n' "$EMAIL" "$(cat "$SIGNING_KEY")" > "$ALLOWED_SIGNERS"
fi

# 6. Stow all packages
# ==================================================================================================
# Back up any real file that a package would claim (e.g. the default ~/.zshrc
# oh-my-zsh just created) so stow can link without a conflict. Symlinks stow
# already owns are left alone.
PACKAGES=(zsh git hammerspoon config home)
BACKUP_DIR="$HOME/.dotfiles-backup"
info "Stowing: ${PACKAGES[*]}"
for pkg in "${PACKAGES[@]}"; do
  # Clear each conflicting target so --restow can link cleanly. readlink -f gives
  # the absolute resolved path (stow writes relative links, so raw readlink can't
  # be compared). Anything resolving into this repo is already ours — including a
  # target reached through a folded parent (~/.config -> repo/config/.config),
  # which must never be moved or we'd gut the repo's own sources.
  find "$pkg" -type f -not -name '.DS_Store' | while IFS= read -r src; do
    rel="${src#"$pkg"/}"          # path relative to $HOME, e.g. .zshrc
    target="$HOME/$rel"
    resolved="$(readlink -f "$target" 2>/dev/null || true)"
    case "$resolved/" in "$DOTFILES_DIR"/*) continue ;; esac
    if [ -L "$target" ]; then
      info "Replacing foreign symlink $rel"; rm -f "$target"
    elif [ -e "$target" ]; then
      info "Backing up existing $rel -> $BACKUP_DIR/$rel"
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$target" "$BACKUP_DIR/$rel"
    fi
  done
  # --no-folding links files individually and keeps target dirs real, instead of
  # collapsing a whole dir into one symlink into the repo (what let apps write
  # state straight into it). Don't let one conflict abort the other packages.
  stow --target="$HOME" --no-folding --restow "$pkg" \
    || warn "stow $pkg had conflicts — check $BACKUP_DIR"
done

# bat only discovers custom themes (~/.config/bat/themes) after a cache build.
if command -v bat >/dev/null 2>&1; then
  info "Rebuilding bat cache..."
  bat cache --build >/dev/null
fi

# 7. macOS system preferences
# ==================================================================================================
info "Applying macOS defaults..."
"$DOTFILES_DIR/macos.sh"

# 8. App preferences (defaults-based utility apps: Rectangle, Itsycal, ...)
# ==================================================================================================
info "Importing app preferences..."
"$DOTFILES_DIR/appdefaults.sh"

# Handy stores config as a JSON file (not a defaults domain). Seed it only if
# absent — never clobber a live file where you've since added API keys.
HANDY_DIR="$HOME/Library/Application Support/com.pais.handy"
if [ ! -f "$HANDY_DIR/settings_store.json" ]; then
  info "Seeding Handy settings..."
  mkdir -p "$HANDY_DIR"
  cp "$DOTFILES_DIR/appdefaults/handy/settings_store.json" "$HANDY_DIR/settings_store.json"
fi

# 9. Celebrate 🎉
# ==================================================================================================
# Must run BEFORE the exec below — exec replaces this process, so nothing after
# it would run. Best-effort; never fails the install.
"$DOTFILES_DIR/celebrate.sh" "Setup done!" || true

# 10. Reload the shell
# ==================================================================================================
# Replace this process with a fresh login zsh so ~/.zshrc is sourced.
info "Reloading zsh..."
exec zsh -l
