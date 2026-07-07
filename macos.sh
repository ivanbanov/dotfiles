#!/usr/bin/env bash
#
# Last verified on macOS 26.5 (Tahoe). `defaults` writes to renamed/removed keys
# fail silently — re-verify this file after every major macOS upgrade.

set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

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

# Free up Cmd+Space: disable Spotlight's hotkey so Raycast can own it
# ==================================================================================================
# Hotkey 64 = "Show Spotlight search" (Cmd+Space), 65 = Finder search window.
# Set enabled=false; needs a logout/login to take effect. This is FLAKY — cfprefsd
# can revert the direct plist edit, so if Cmd+Space still opens Spotlight, disable
# it by hand (System Settings > Keyboard > Keyboard Shortcuts > Spotlight). See README.
# (Set Raycast's hotkey to Cmd+Space in its own settings — that part isn't scriptable.)
PB=/usr/libexec/PlistBuddy
SHK="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
for id in 64 65; do
  $PB -c "Set :AppleSymbolicHotKeys:$id:enabled false" "$SHK" 2>/dev/null \
    || $PB -c "Add :AppleSymbolicHotKeys:$id:enabled bool false" "$SHK" 2>/dev/null \
    || true
done

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
# Three-finger drag. NOTE: only takes effect after a logout/login — a killall
# can't reload the daemon that owns trackpad prefs. On recent macOS this setting
# lives under Accessibility > Pointer Control and may need enabling there once.
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
# Faster mouse tracking
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5
# NOTE: Control+scroll to zoom (Accessibility > Zoom) can't be scripted — its
# com.apple.universalaccess domain is TCC-protected and needs Full Disk Access.
# Enable it manually; see the README.

# Finder
# ==================================================================================================
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Breadcrumb path bar + status bar (item count / free space)
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Screenshots: no drop shadow, no floating thumbnail
# ==================================================================================================
defaults write com.apple.screencapture show-thumbnail -bool false
defaults write com.apple.screencapture disable-shadow -bool true

# Menu bar: clock + Control Center modules
# ==================================================================================================
# NOTE: only the system/Control-Center items live here. Third-party icons
# (Raycast, Stats, 1Password, ...) are toggled inside each app, and their
# left-right order is set once by Cmd-dragging — neither is scriptable.
# Clock: digital, 24h, no date (2 = never; Itsycal shows the date), no day-of-week
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowDate -int 2
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false
# Control Center: show battery, Bluetooth, Wi-Fi, clock; hide sound/now-playing/etc.
defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible ScreenMirroring" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible AudioVideoModule" -bool false
# Hide the battery percentage (matches current setup; flip to true to show it)
defaults write com.apple.controlcenter BatteryShowPercentage -bool false

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

# Dock: auto-hide always; empty it only when explicitly asked
# ==================================================================================================
defaults write com.apple.dock autohide -bool true
# Magnify on hover
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 71
# Clearing the Dock is destructive, so it's opt-in: run `CLEAR_DOCK=1 ./macos.sh`
# (or set it before install.sh) on a fresh machine. Never fires on a plain re-run.
if [ "${CLEAR_DOCK:-0}" = "1" ]; then
  info "CLEAR_DOCK=1 — clearing all apps from the Dock."
  defaults write com.apple.dock persistent-apps -array
fi

# Apply
# ==================================================================================================
# cfprefsd first so the direct symbolichotkeys plist edit isn't cached over.
for app in cfprefsd Dock Finder SystemUIServer ControlCenter; do
  killall "$app" >/dev/null 2>&1 || true
done
info "macOS defaults applied."
warn "Log out and back in (or reboot) for keyboard/trackpad/Spotlight settings"
warn "(three-finger drag, tap-to-click, key repeat, Cmd+Space) to take effect."
warn "Then set Raycast's hotkey to Cmd+Space in Raycast > Settings."
