#!/usr/bin/env bash
# Idempotent: safe to re-run. It stows packages with GNU Stow.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

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

# 3. oh-my-zsh + plugins
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

# 6. Stow all packages
# ==================================================================================================
PACKAGES=(zsh git hammerspoon config)
info "Stowing: ${PACKAGES[*]}"
for pkg in "${PACKAGES[@]}"; do
  stow --target="$HOME" --restow "$pkg"
done

# 7. macOS system preferences
# ==================================================================================================
info "Applying macOS defaults..."
"$DOTFILES_DIR/macos.sh"

info "Done. Remember to set the WakaTime key in Zed."

# 8. Celebrate 🎉
# ==================================================================================================
# Must run BEFORE the exec below — exec replaces this process, so nothing after
# it would run. Best-effort; never fails the install.
"$DOTFILES_DIR/celebrate.sh" "Setup done!" || true

# 9. Reload the shell
# ==================================================================================================
# Replace this process with a fresh login zsh so ~/.zshrc is sourced.
info "Reloading zsh..."
exec zsh -l
