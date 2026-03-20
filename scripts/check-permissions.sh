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

# Classify risk for each entry.
# Order matters: specific patterns before broad catch-alls within each tool.
# Levels: safe (read-only) < low (local writes, reversible) < medium (limited
# blast radius) < HIGH (destructive, remote, or unscoped wildcards) < UNKNOWN.
classify_risk() {
  local entry="$1"
  case "$entry" in

    # ── Read / WebFetch ──────────────────────────────────────────────────
    Read\(*)
      echo "safe     read-only, no side effects"
      ;;
    WebFetch\(domain:*)
      echo "safe     read-only fetch from specific domain"
      ;;
    WebFetch\(*)
      echo "low      network fetch from unscoped domain"
      ;;

    # ── Bash: safe — informational / read-only ───────────────────────────
    Bash\(printenv:*|Bash\(env\)|Bash\(env\ *|Bash\(date*|Bash\(whoami*|Bash\(pwd*|Bash\(which:*|Bash\(wc:*|Bash\(id\ *|Bash\(id\)|Bash\(hostname*|Bash\(uname*)
      echo "safe     informational, no side effects"
      ;;
    Bash\(~/.bashrc\)|Bash\(source:*)
      echo "safe     sources shell profile"
      ;;
    Bash\(ls:*|Bash\(ls\ *|Bash\(cat:*|Bash\(head:*|Bash\(tail:*|Bash\(grep:*|Bash\(rg:*|Bash\(find:*|Bash\(sort:*|Bash\(base64:*|Bash\(diff:*|Bash\(file:*|Bash\(stat:*|Bash\(du:*|Bash\(df:*|Bash\(tree:*|Bash\(realpath:*|Bash\(dirname:*|Bash\(basename:*|Bash\(readlink:*|Bash\(test:*|Bash\(\[:*)
      echo "safe     read-only command"
      ;;
    Bash\(echo:*|Bash\(printf:*|Bash\(true*|Bash\(false*)
      echo "safe     output only"
      ;;
    Bash\(jq:*|Bash\(yq:*|Bash\(column:*|Bash\(cut:*|Bash\(tr:*|Bash\(uniq:*|Bash\(tac:*|Bash\(rev:*|Bash\(paste:*|Bash\(comm:*|Bash\(join:*)
      echo "safe     text processing — read-only"
      ;;
    Bash\(xargs:*)
      echo "medium   runs arbitrary commands via pipeline"
      ;;

    # ── Bash: git — scoped subcommands ───────────────────────────────────
    Bash\(git\ status:*|Bash\(git\ log:*|Bash\(git\ diff:*|Bash\(git\ show:*|Bash\(git\ branch:*|Bash\(git\ remote:*|Bash\(git\ rev-*|Bash\(git\ ls-files:*|Bash\(git\ ls-tree:*|Bash\(git\ config:*|Bash\(git\ tag:*|Bash\(git\ blame:*|Bash\(git\ shortlog:*|Bash\(git\ describe:*|Bash\(git\ name-rev:*|Bash\(git\ for-each-ref:*|Bash\(git\ cat-file:*|Bash\(git\ count-objects:*)
      echo "safe     read-only git operation"
      ;;
    Bash\(git\ add:*|Bash\(git\ commit:*|Bash\(git\ stash:*|Bash\(git\ fetch:*|Bash\(git\ pull:*|Bash\(git\ switch:*|Bash\(git\ checkout:*|Bash\(git\ merge:*|Bash\(git\ cherry-pick:*|Bash\(git\ worktree:*|Bash\(git\ init:*|Bash\(git\ clone:*)
      echo "low      local git write — reversible"
      ;;
    Bash\(git\ push:*|Bash\(git\ rebase:*|Bash\(git\ reset:*|Bash\(git\ clean:*|Bash\(git\ branch\ -[dD]:*|Bash\(git\ branch\ --delete:*)
      echo "HIGH     affects remote, rewrites history, or destroys work"
      ;;
    # Unscoped git wildcard — must come after scoped patterns
    Bash\(git:*)
      echo "HIGH     unscoped git wildcard — covers push, reset --hard, clean -f, etc."
      ;;

    # ── Bash: gh — scoped subcommands ────────────────────────────────────
    Bash\(gh\ auth:*|Bash\(gh\ pr\ list:*|Bash\(gh\ pr\ view:*|Bash\(gh\ pr\ checks:*|Bash\(gh\ pr\ diff:*|Bash\(gh\ pr\ status:*|Bash\(gh\ issue\ list:*|Bash\(gh\ issue\ view:*|Bash\(gh\ issue\ status:*|Bash\(gh\ repo\ list:*|Bash\(gh\ repo\ view:*|Bash\(gh\ run\ list:*|Bash\(gh\ run\ view:*|Bash\(gh\ api\ */repos/*/pulls/*|Bash\(gh\ api\ */repos/*/issues/*)
      echo "safe     read-only GitHub operation"
      ;;
    Bash\(gh\ pr\ create:*|Bash\(gh\ pr\ comment:*|Bash\(gh\ pr\ edit:*|Bash\(gh\ pr\ review:*|Bash\(gh\ pr\ ready:*|Bash\(gh\ issue\ create:*|Bash\(gh\ issue\ comment:*|Bash\(gh\ issue\ edit:*|Bash\(gh\ release\ create:*|Bash\(gh\ gist\ create:*|Bash\(gh\ run\ rerun:*)
      echo "medium   GitHub write — creates or modifies resources"
      ;;
    Bash\(gh\ pr\ close:*|Bash\(gh\ pr\ merge:*|Bash\(gh\ issue\ close:*|Bash\(gh\ issue\ delete:*|Bash\(gh\ repo\ delete:*|Bash\(gh\ release\ delete:*|Bash\(gh\ gist\ delete:*|Bash\(gh\ run\ cancel:*)
      echo "HIGH     GitHub destructive — closes, merges, or deletes resources"
      ;;
    # Unscoped gh / GH_TOKEN wildcard — must come after scoped patterns
    Bash\(gh:*|Bash\(GH_TOKEN:*)
      echo "HIGH     unscoped gh wildcard — covers close, merge, delete, etc."
      ;;

    # ── Bash: file operations ────────────────────────────────────────────
    Bash\(mkdir:*|Bash\(touch:*|Bash\(cp:*|Bash\(chmod:*|Bash\(ln:*|Bash\(install\ *)
      echo "low      creates/copies files or changes permissions"
      ;;
    Bash\(sed:*|Bash\(awk:*|Bash\(tee:*)
      echo "low      text processing — can modify files in-place"
      ;;
    Bash\(mv:*)
      echo "medium   moves/renames files"
      ;;
    Bash\(rm\ -rf:*|Bash\(rm\ -r:*|Bash\(rm\ --recursive:*)
      echo "HIGH     recursive delete"
      ;;
    Bash\(rm:*)
      echo "medium   deletes files"
      ;;

    # ── Bash: privileged operations ──────────────────────────────────────
    Bash\(sudo\ rm:*|Bash\(sudo\ mv:*|Bash\(sudo\ chmod:*|Bash\(sudo\ chown:*)
      echo "HIGH     privileged destructive operation"
      ;;
    Bash\(sudo\ *)
      echo "medium   privileged operation"
      ;;

    # ── Bash: network ───────────────────────────────────────────────────
    Bash\(curl:*|Bash\(wget:*|Bash\(ssh:*|Bash\(scp:*|Bash\(rsync:*)
      echo "medium   network request — can send data or access remote systems"
      ;;

    # ── Bash: package managers / runtimes ────────────────────────────────
    Bash\(npm:*|Bash\(npx:*|Bash\(yarn:*|Bash\(pnpm:*|Bash\(pip:*|Bash\(pip3:*|Bash\(composer:*|Bash\(cargo:*|Bash\(go\ get:*|Bash\(go\ install:*|Bash\(apt:*|Bash\(apt-get:*|Bash\(brew:*)
      echo "medium   package manager — can install/run code"
      ;;
    Bash\(node:*|Bash\(python:*|Bash\(python3:*|Bash\(php:*|Bash\(ruby:*|Bash\(go\ run:*|Bash\(deno:*|Bash\(bun:*)
      echo "medium   arbitrary code execution"
      ;;

    # ── Bash: databases ─────────────────────────────────────────────────
    Bash\(mysql:*|Bash\(psql:*|Bash\(sqlite3:*|Bash\(mongo:*|Bash\(redis-cli:*)
      echo "medium   database access — can read/write data"
      ;;

    # ── Bash: containers / infra ─────────────────────────────────────────
    Bash\(docker:*|Bash\(docker-compose:*|Bash\(podman:*|Bash\(kubectl:*|Bash\(terraform:*)
      echo "medium   container/infra operation"
      ;;

    # ── Bash: other tools ────────────────────────────────────────────────
    Bash\(claude:*)
      echo "medium   spawns Claude subprocess"
      ;;
    Bash\(tar:*|Bash\(unzip:*|Bash\(zip:*|Bash\(gzip:*|Bash\(gunzip:*)
      echo "low      archive operation"
      ;;
    Bash\(export:*|Bash\(export\ *)
      echo "low      sets environment variable — may chain to other commands"
      ;;
    Bash\(cd:*|Bash\(cd\ *|Bash\(pushd:*|Bash\(popd*)
      echo "safe     changes directory"
      ;;
    Bash\(type:*|Bash\(command:*|Bash\(hash:*|Bash\(alias:*|Bash\(set:*|Bash\(shopt:*)
      echo "safe     shell built-in — informational"
      ;;
    Bash\(wg:*|Bash\(wg\ *|Bash\(wg-quick:*)
      echo "medium   VPN/network configuration"
      ;;

    # ── Shell syntax fragments from multi-line command approvals ─────────
    Bash\(for\ *|Bash\(for:*|Bash\(do\ *|Bash\(do\)|Bash\(done*|Bash\(if\ *|Bash\(if:*|Bash\(then*|Bash\(else*|Bash\(fi\)|Bash\(fi\ *|Bash\(while\ *|Bash\(while:*|Bash\(until\ *|Bash\(until:*|Bash\(case\ *|Bash\(esac*|Bash\(\{*|Bash\(\}*|Bash\(\[\[*)
      echo "LOW      shell syntax fragment from multi-line approval — not useful standalone"
      ;;

    # ── Catch-all ────────────────────────────────────────────────────────
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
