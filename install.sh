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

# Create .claude-docs directory in all git repositories
find /workspaces -name ".git" -type d 2>/dev/null | while read -r GIT_DIR; do
  PROJECT_ROOT=$(dirname "$GIT_DIR")
  CLAUDE_DOCS_DIR="$PROJECT_ROOT/.claude-docs"

  # Skip if already exists
  if [[ ! -d "$CLAUDE_DOCS_DIR" ]]; then
    mkdir -p "$CLAUDE_DOCS_DIR"
    echo "📁 Created .claude-docs at $CLAUDE_DOCS_DIR"
  fi

  # Add to git exclude if not already present
  GIT_EXCLUDE="$GIT_DIR/info/exclude"
  if ! grep -q "^\.claude-docs/$" "$GIT_EXCLUDE" 2>/dev/null; then
    echo ".claude-docs/" >> "$GIT_EXCLUDE"
    echo "   Added .claude-docs/ to git exclude"
  fi
done

echo "✅ Dotfiles setup complete!"