#!/usr/bin/env bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting git commit signing setup..."

if [[ -z "${MIKE_GIT_SIGNING_KEY:-}" ]]; then
  log "⚠️  MIKE_GIT_SIGNING_KEY not set — skipping git signing setup"
  exit 0
fi

KEY_FILE="$HOME/.ssh/git_signing_key"
PUB_FILE="$KEY_FILE.pub"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# The secret may be stored either with or without PEM armor. Wrap if missing.
if [[ "$MIKE_GIT_SIGNING_KEY" == -----BEGIN* ]]; then
  printenv MIKE_GIT_SIGNING_KEY > "$KEY_FILE"
else
  {
    echo "-----BEGIN OPENSSH PRIVATE KEY-----"
    printenv MIKE_GIT_SIGNING_KEY
    echo "-----END OPENSSH PRIVATE KEY-----"
  } > "$KEY_FILE"
fi
chmod 600 "$KEY_FILE"

if ! ssh-keygen -y -f "$KEY_FILE" > "$PUB_FILE" 2>/dev/null; then
  log "❌ MIKE_GIT_SIGNING_KEY did not parse as a valid SSH private key"
  rm -f "$KEY_FILE" "$PUB_FILE"
  exit 1
fi
chmod 644 "$PUB_FILE"

git config --global gpg.format ssh
git config --global user.signingkey "$PUB_FILE"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

log "✓ Git SSH signing configured ($(awk '{print $1, substr($2,1,16)"..."}' "$PUB_FILE"))"
