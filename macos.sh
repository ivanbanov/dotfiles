#!/usr/bin/env bash
# macOS system preferences via `defaults write`.
#
# Idempotent for the always-on tweaks (safe to re-run). The destructive
# fresh-machine bits (wiping the Dock) run ONLY once, guarded by a sentinel so
# a re-run never nukes a Dock you've since customised.
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

SENTINEL="$HOME/.config/.macos-defaults-applied"

# Keyboard: press-and-hold repeats, at max speed
# ==================================================================================================
# Hold a key to repeat (instead of the accent popover)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Fastest repeat rate + short initial delay (units are 15ms ticks)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Hot corners  (0 none · 5 screensaver · 4 desktop; modifier 0 = no key)
# ==================================================================================================
# Bottom-left: start screen saver (locks, given the password setting below)
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom-right: show desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0
# Require the password immediately after screen saver starts (makes bl == lock)
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Dock: auto-hide always; empty it only on a fresh machine
# ==================================================================================================
defaults write com.apple.dock autohide -bool true
if [ ! -f "$SENTINEL" ]; then
  info "Fresh machine — clearing all apps from the Dock."
  defaults write com.apple.dock persistent-apps -array
fi

# Apply
# ==================================================================================================
killall Dock >/dev/null 2>&1 || true
mkdir -p "$(dirname "$SENTINEL")"
touch "$SENTINEL"
info "macOS defaults applied. Some keyboard settings need a logout/login."
