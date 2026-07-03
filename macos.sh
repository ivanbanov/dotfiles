#!/usr/bin/env bash

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
# Tab through every control in dialogs, not just text fields/lists
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
# 24-hour clock
defaults write NSGlobalDomain AppleICUForce12HourTime -bool false

# Text input: no autocorrect / smart substitutions
# ==================================================================================================
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Trackpad & mouse
# ==================================================================================================
# Tap to click (per-device + global fallback for the login screen)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
# Faster mouse tracking
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5

# Finder
# ==================================================================================================
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Screenshots: no drop shadow, no floating thumbnail
# ==================================================================================================
defaults write com.apple.screencapture show-thumbnail -bool false
defaults write com.apple.screencapture disable-shadow -bool true

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
# Magnify on hover
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 71
if [ ! -f "$SENTINEL" ]; then
  info "Fresh machine — clearing all apps from the Dock."
  defaults write com.apple.dock persistent-apps -array
fi

# Apply
# ==================================================================================================
for app in Dock Finder SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done
mkdir -p "$(dirname "$SENTINEL")"
touch "$SENTINEL"
info "macOS defaults applied. Some keyboard/input settings need a logout/login."
