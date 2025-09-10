#!/bin/bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

echo "🚀 Setting up personal development environment..."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting dotfiles installation" | tee -a "$LOG_FILE"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_INSTALL="$SCRIPT_DIR/install-claude.sh"

echo "📦 Installing Claude Code..."
if [[ -f "$CLAUDE_INSTALL" ]]; then
  chmod +x "$CLAUDE_INSTALL"
  bash "$CLAUDE_INSTALL"
else
  echo "❌ Error: $CLAUDE_INSTALL not found."
  exit 1
fi

echo "✅ Dotfiles setup complete!"