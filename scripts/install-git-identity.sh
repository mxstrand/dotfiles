#!/usr/bin/env bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Set the global git identity to the GitHub no-reply form so commits authored
# in fresh codespaces don't embed a personal email in public commit history.
git config --global user.name "Mike Strand"
git config --global user.email "3622461+mxstrand@users.noreply.github.com"

log "✓ Git identity set ($(git config --global user.name) <$(git config --global user.email)>)"
