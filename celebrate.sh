#!/usr/bin/env bash

set -uo pipefail

MSG="${1:-Setup done!}"

# 1. Terminal banner (always works)
# ==================================================================================================
printf '\n\033[1;35m🎉  %s  🎉\033[0m\n\n' "$MSG"

# 2. Native macOS notification (no-op if osascript/GUI unavailable)
# ==================================================================================================
if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"${MSG}\" with title \"🎉 dotfiles\" sound name \"Glass\"" \
    >/dev/null 2>&1 || true
fi

# 3. Native on-screen confetti via Raycast's deeplink (needs Raycast installed)
# ==================================================================================================
if command -v open >/dev/null 2>&1; then
  open "raycast://confetti" >/dev/null 2>&1 || true
fi
