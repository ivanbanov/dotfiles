#!/usr/bin/env bash
# Import saved app preference domains (utility apps that store settings in
# macOS `defaults` rather than a config file). Each appdefaults/<domain>.plist
# is imported back into its domain. Best-effort; never fails the caller.
#
# To re-capture after changing an app's settings:
#   defaults export <domain> appdefaults/<domain>.plist
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/appdefaults"
[ -d "$DIR" ] || exit 0

for plist in "$DIR"/*.plist; do
  [ -e "$plist" ] || continue
  domain="$(basename "$plist" .plist)"
  printf '\033[1;34m==>\033[0m Importing %s\n' "$domain"
  defaults import "$domain" "$plist" 2>/dev/null || true
done
