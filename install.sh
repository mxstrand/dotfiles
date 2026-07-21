#!/bin/bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

echo "🚀 Setting up personal development environment..."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting dotfiles installation" | tee -a "$LOG_FILE"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_INSTALL="$SCRIPT_DIR/scripts/install-claude.sh"

echo "📦 Installing Claude Code..."
if [[ -f "$CLAUDE_INSTALL" ]]; then
  chmod +x "$CLAUDE_INSTALL"
  # Ensure output is visible during Codespace creation
  "$CLAUDE_INSTALL" 2>&1
else
  echo "❌ Error: $CLAUDE_INSTALL not found."
  exit 1
fi

echo "🔒 Installing WireGuard VPN..."
WIREGUARD_INSTALL="$SCRIPT_DIR/scripts/install-wireguard.sh"
if [[ -f "$WIREGUARD_INSTALL" ]]; then
  chmod +x "$WIREGUARD_INSTALL"
  "$WIREGUARD_INSTALL" 2>&1
else
  echo "⚠️  WireGuard installation script not found (skipping)"
fi

echo "👤 Configuring git identity..."
IDENTITY_INSTALL="$SCRIPT_DIR/scripts/install-git-identity.sh"
if [[ -f "$IDENTITY_INSTALL" ]]; then
  chmod +x "$IDENTITY_INSTALL"
  "$IDENTITY_INSTALL" 2>&1
else
  echo "⚠️  Git identity installation script not found (skipping)"
fi

echo "🔑 Configuring git commit signing..."
SIGNING_INSTALL="$SCRIPT_DIR/scripts/install-git-signing.sh"
if [[ -f "$SIGNING_INSTALL" ]]; then
  chmod +x "$SIGNING_INSTALL"
  "$SIGNING_INSTALL" 2>&1
else
  echo "⚠️  Git signing installation script not found (skipping)"
fi

# Symlink AGENTS.md to CLAUDE.md (excluding commands directories)
find /workspaces -name "AGENTS.md" -type f ! -path "*/commands/*" 2>/dev/null | while read -r AGENTS_FILE; do
  AGENTS_DIR=$(dirname "$AGENTS_FILE")
  CLAUDE_MD="$AGENTS_DIR/CLAUDE.md"
  if [[ ! -e "$CLAUDE_MD" ]]; then
    ln -s "$AGENTS_FILE" "$CLAUDE_MD"
    echo "🔗 Linked $AGENTS_FILE to CLAUDE.md"
  fi
done

# Keep dotfiles-generated files out of git status in every repo — the
# CLAUDE.md symlinks and .claude-docs/ dirs are machine-local, never
# committed. Global excludesFile (not per-repo .git/info/exclude) so repos
# cloned after provisioning are covered too.
GLOBAL_GITIGNORE="$HOME/.config/git/ignore"
mkdir -p "$(dirname "$GLOBAL_GITIGNORE")"
for pattern in "CLAUDE.md" ".claude-docs/"; do
  grep -qxF "$pattern" "$GLOBAL_GITIGNORE" 2>/dev/null || echo "$pattern" >> "$GLOBAL_GITIGNORE"
done
git config --global core.excludesFile "$GLOBAL_GITIGNORE"
echo "🙈 Global gitignore excludes CLAUDE.md + .claude-docs/ ($GLOBAL_GITIGNORE)"

# Create .claude-docs directory in all git repositories
find /workspaces -name ".git" -type d 2>/dev/null | while read -r GIT_DIR; do
  PROJECT_ROOT=$(dirname "$GIT_DIR")
  CLAUDE_DOCS_DIR="$PROJECT_ROOT/.claude-docs"

  # Skip if already exists
  if [[ ! -d "$CLAUDE_DOCS_DIR" ]]; then
    mkdir -p "$CLAUDE_DOCS_DIR"
    echo "📁 Created .claude-docs at $CLAUDE_DOCS_DIR"
  fi
done

echo "✅ Dotfiles setup complete!"