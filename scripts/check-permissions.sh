#!/usr/bin/env bash
set -euo pipefail
# Stop hook: compares project settings.local.json against global settings.json.
# Silent when clean. Writes new entries to .claude-docs/pending-promotions.txt
# with risk assessment to help decide whether to promote to the global allow list.

GLOBAL="$HOME/.claude/settings.json"
LOCAL="${PWD}/.claude/settings.local.json"

[[ -f "$GLOBAL" && -f "$LOCAL" ]] || exit 0

mapfile -t new_entries < <(
  jq -r --slurpfile global "$GLOBAL" '
    (.permissions.allow // []) - ($global[0].permissions.allow // []) | .[]
  ' "$LOCAL" 2>/dev/null
)

PROMOTIONS_FILE="${PWD}/.claude-docs/pending-promotions.txt"

if [[ ${#new_entries[@]} -eq 0 ]]; then
  rm -f "$PROMOTIONS_FILE"
  exit 0
fi

# Classify risk for each entry
classify_risk() {
  local entry="$1"
  case "$entry" in
    Read\(*)
      echo "safe     read-only, no side effects"
      ;;
    WebFetch\(domain:*)
      echo "safe     read-only fetch from specific domain"
      ;;
    Bash\(printenv:*|Bash\(env\)|Bash\(date\)|Bash\(whoami\)|Bash\(pwd\)|Bash\(which:*|Bash\(wc:*)
      echo "safe     informational, no side effects"
      ;;
    Bash\(~/.bashrc\)|Bash\(source:*)
      echo "safe     sources shell profile"
      ;;
    Bash\(ls:*|Bash\(cat:*|Bash\(head:*|Bash\(tail:*|Bash\(grep:*|Bash\(find:*|Bash\(sort:*|Bash\(base64:*)
      echo "safe     read-only command"
      ;;
    Bash\(echo:*|Bash\(printf:*)
      echo "safe     output only"
      ;;
    Bash\(git\ status:*|Bash\(git\ log:*|Bash\(git\ diff:*|Bash\(git\ show:*|Bash\(git\ branch:*|Bash\(git\ remote:*|Bash\(git\ rev-*|Bash\(git\ ls-files:*|Bash\(git\ config:*|Bash\(git\ tag:*)
      echo "safe     read-only git operation"
      ;;
    Bash\(git\ add:*|Bash\(git\ commit:*|Bash\(git\ stash:*|Bash\(git\ fetch:*|Bash\(git\ pull:*|Bash\(git\ switch:*|Bash\(git\ checkout:*|Bash\(git\ merge:*|Bash\(git\ cherry-pick:*)
      echo "low      local git write — reversible"
      ;;
    Bash\(git\ push:*|Bash\(git\ rebase:*)
      echo "medium   affects remote or rewrites history"
      ;;
    Bash\(mkdir:*|Bash\(touch:*|Bash\(cp:*|Bash\(chmod:*)
      echo "low      creates/copies files or changes permissions"
      ;;
    Bash\(mv:*|Bash\(rm:*)
      echo "medium   moves or deletes files"
      ;;
    Bash\(sudo\ rm:*|Bash\(sudo\ mv:*)
      echo "HIGH     privileged destructive operation"
      ;;
    Bash\(sudo\ *)
      echo "medium   privileged operation"
      ;;
    Bash\(curl:*)
      echo "medium   network request — can send data"
      ;;
    Bash\(npm:*|Bash\(npx:*|Bash\(pip:*|Bash\(pip3:*|Bash\(composer:*)
      echo "medium   package manager — can install/run code"
      ;;
    Bash\(node:*|Bash\(python:*|Bash\(python3:*|Bash\(php:*)
      echo "medium   arbitrary code execution"
      ;;
    Bash\(gh:*|Bash\(GH_TOKEN:*)
      echo "medium   GitHub API — can modify repos, PRs, issues"
      ;;
    Bash\(claude:*)
      echo "medium   spawns Claude subprocess"
      ;;
    Bash\(mysql:*)
      echo "medium   database access — can read/write data"
      ;;
    Bash\(sed:*|Bash\(awk:*)
      echo "low      text processing — can modify files in-place"
      ;;
    WebFetch\(*)
      echo "low      network fetch from unscoped domain"
      ;;
    *)
      echo "UNKNOWN  review manually before promoting"
      ;;
  esac
}

mkdir -p "${PWD}/.claude-docs"

{
  echo "# Pending permission promotions"
  echo "# Detected: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# Rules in .claude/settings.local.json not yet in global settings.json"
  echo "# Promote safe/low entries to dotfiles/scripts/install-claude.sh"
  echo "#"
  echo "# RISK     ENTRY"
  for entry in "${new_entries[@]}"; do
    risk=$(classify_risk "$entry")
    printf "# %-8s %s\n" "$(echo "$risk" | cut -d' ' -f1)" "$entry"
    echo "#          $(echo "$risk" | sed 's/^[^ ]* *//')"
  done
  echo ""
  for entry in "${new_entries[@]}"; do
    echo "$entry"
  done
} > "$PROMOTIONS_FILE"
