#!/usr/bin/env bash
# Stop hook: compares project settings.local.json against global settings.json.
# Silent when clean. Surfaces new entries as candidates to promote to install-claude.sh.

GLOBAL="$HOME/.claude/settings.json"
LOCAL="${PWD}/.claude/settings.local.json"

[[ -f "$GLOBAL" && -f "$LOCAL" ]] || exit 0

mapfile -t new_entries < <(
  jq -r --slurpfile global "$GLOBAL" '
    (.permissions.allow // []) - ($global[0].permissions.allow // []) | .[]
  ' "$LOCAL" 2>/dev/null
)

[[ ${#new_entries[@]} -eq 0 ]] && exit 0

echo ""
echo "⚙️  ${#new_entries[@]} permission rule(s) in settings.local.json not in global settings.json:"
for entry in "${new_entries[@]}"; do
  echo "   $entry"
done
echo "   → Consider promoting these to dotfiles scripts/install-claude.sh"
