#!/bin/bash
set -Eeuo pipefail

echo "🚀 Setting up personal development environment..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_INSTALL="$SCRIPT_DIR/install-claude.sh"

if [[ ! -f "$CLAUDE_INSTALL" ]]; then
  echo "❌ Error: $CLAUDE_INSTALL not found."
  exit 1
fi

chmod +x "$CLAUDE_INSTALL"

echo "📦 Installing Claude Code..."
bash "$CLAUDE_INSTALL"   # 👈 force bash

echo "✅ Dotfiles setup complete!"
