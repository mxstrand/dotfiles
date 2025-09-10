#!/bin/bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

echo "🚀 Setting up personal development environment..."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting dotfiles installation" | tee -a "$LOG_FILE"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE_INSTALL="$SCRIPT_DIR/install-claude.sh"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script directory: $SCRIPT_DIR" | tee -a "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude install script path: $CLAUDE_INSTALL" | tee -a "$LOG_FILE"

if [[ ! -f "$CLAUDE_INSTALL" ]]; then
  echo "❌ Error: $CLAUDE_INSTALL not found."
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] File listing in script directory:" | tee -a "$LOG_FILE"
  ls -la "$SCRIPT_DIR" 2>&1 | tee -a "$LOG_FILE" || true
  exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Making Claude install script executable" | tee -a "$LOG_FILE"
chmod +x "$CLAUDE_INSTALL"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Environment check - USER=$USER HOME=$HOME PWD=$PWD" | tee -a "$LOG_FILE"

echo "📦 Installing Claude Code..."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] About to execute: bash $CLAUDE_INSTALL" | tee -a "$LOG_FILE"

# Capture both stdout and stderr, and exit codes
if bash "$CLAUDE_INSTALL" 2>&1 | tee -a "$LOG_FILE"; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude install script completed successfully" | tee -a "$LOG_FILE"
  echo "✅ Dotfiles setup complete!"
else
  EXIT_CODE=$?
  echo "❌ Claude install script failed with exit code: $EXIT_CODE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude install script failed with exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
  exit $EXIT_CODE
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log file available at: $LOG_FILE" | tee -a "$LOG_FILE"
