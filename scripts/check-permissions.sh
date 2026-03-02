#!/usr/bin/env bash
set -euo pipefail
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

# Output additionalContext JSON — Claude Code injects this into Claude's context
# on the next turn so it can surface the findings in its response.
# (Hooks run without a tty in Codespaces, so /dev/tty and plain stdout don't reach the user.)
msg="⚙️ ${#new_entries[@]} permission rule(s) in .claude/settings.local.json not yet in global settings.json:"
for entry in "${new_entries[@]}"; do
  msg+=$'\n'"  $entry"
done
msg+=$'\n'"  → Consider promoting these to dotfiles/scripts/install-claude.sh"

jq -n --arg msg "$msg" '{"additionalContext": $msg}'
