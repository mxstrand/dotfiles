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

# Symlink AGENTS.md to CLAUDE.md recursively in all workspaces
find /workspaces -name "AGENTS.md" -type f 2>/dev/null | while read -r AGENTS_FILE; do
  AGENTS_DIR=$(dirname "$AGENTS_FILE")
  CLAUDE_MD="$AGENTS_DIR/CLAUDE.md"
  if [[ ! -e "$CLAUDE_MD" ]]; then
    ln -s "$AGENTS_FILE" "$CLAUDE_MD"
    echo "🔗 Linked $AGENTS_FILE to CLAUDE.md"
  fi
done

echo "✅ Dotfiles setup complete!"