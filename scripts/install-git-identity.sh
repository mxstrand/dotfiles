#!/usr/bin/env bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Set the global git identity to the GitHub no-reply form so commits authored
# in fresh codespaces don't embed a personal email in public commit history.
NAME="Mike Strand"
EMAIL="3622461+mxstrand@users.noreply.github.com"
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

log "✓ Git identity set ($(git config --global user.name) <$(git config --global user.email)>)"

# Codespaces injects GIT_COMMITTER_NAME=GitHub / GIT_COMMITTER_EMAIL=noreply@github.com
# at the container level. Git uses those env vars over user.email for the committer,
# so commits land with committer "GitHub <noreply@github.com>" — an address not tied
# to the account, which makes signed commits show as "Unverified" on GitHub.
# Pin author+committer to the verified identity in the shell profiles so every
# session commits (and signs) as the right person.
identity_block=$(cat <<EOF

# Pin git author/committer over the Codespaces-injected GIT_COMMITTER_* env vars
# (otherwise the committer is "GitHub <noreply@github.com>" and signatures show Unverified).
export GIT_AUTHOR_NAME="$NAME"
export GIT_AUTHOR_EMAIL="$EMAIL"
export GIT_COMMITTER_NAME="$NAME"
export GIT_COMMITTER_EMAIL="$EMAIL"
EOF
)
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
  if ! grep -q 'GIT_COMMITTER_EMAIL' "$rc" 2>/dev/null; then
    printf '%s\n' "$identity_block" >> "$rc"
    log "✓ Pinned git committer identity in $rc"
  fi
done
