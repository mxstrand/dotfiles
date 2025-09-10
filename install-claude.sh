#!/usr/bin/env bash
set -Eeuo pipefail

LOG_FILE="/tmp/claude-install.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Claude Code installation" | tee -a "$LOG_FILE"

# If already installed, bail out early
if command -v claude >/dev/null 2>&1; then
  CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
  echo "Claude Code is already installed"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude already installed - version: $CLAUDE_VERSION at $(which claude)" | tee -a "$LOG_FILE"
  exit 0
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude not found, proceeding with installation" | tee -a "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Environment - OS: $(uname -s), Arch: $(uname -m), User: $USER, Home: $HOME" | tee -a "$LOG_FILE"

echo "Installing Claude Code..."

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Testing network connectivity to claude.ai" | tee -a "$LOG_FILE"
if ! curl -I https://claude.ai >/dev/null 2>&1; then
  echo "❌ Network connectivity test failed - cannot reach claude.ai"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Network test failed" | tee -a "$LOG_FILE"
  exit 1
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Network connectivity OK" | tee -a "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Downloading and executing official installer" | tee -a "$LOG_FILE"
# Official installer (macOS/Linux/WSL)
if ! curl -fsSL https://claude.ai/install.sh 2>&1 | tee -a "$LOG_FILE" | bash 2>&1 | tee -a "$LOG_FILE"; then
  echo "❌ Claude Code installation failed (installer returned non-zero)"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installer script failed" | tee -a "$LOG_FILE"
  exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installer completed, verifying installation" | tee -a "$LOG_FILE"

# Verify installation
if command -v claude >/dev/null 2>&1; then
  CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
  echo "✅ Claude Code installed successfully"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude installed at: $(which claude), version: $CLAUDE_VERSION" | tee -a "$LOG_FILE"
else
  echo "❌ Claude Code installation failed (binary not on PATH)"
  echo "   Try opening a new shell or ensure the installer's bin dir is on PATH."
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude binary not found on PATH after installation" | tee -a "$LOG_FILE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Current PATH: $PATH" | tee -a "$LOG_FILE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking ~/.local/bin/claude: $(ls -la ~/.local/bin/claude 2>/dev/null || echo 'not found')" | tee -a "$LOG_FILE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking /usr/local/bin/claude: $(ls -la /usr/local/bin/claude 2>/dev/null || echo 'not found')" | tee -a "$LOG_FILE"
  exit 1
fi

# Setup authentication if token is available
if [[ -n "${CLAUDE_INSTALL_TOKEN:-}" ]]; then
  echo "🔐 Setting up Claude authentication..."
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] CLAUDE_INSTALL_TOKEN found, setting up authentication" | tee -a "$LOG_FILE"
  
  # Set the API key as environment variable for Claude Code
  export ANTHROPIC_API_KEY="$CLAUDE_INSTALL_TOKEN"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Set ANTHROPIC_API_KEY environment variable" | tee -a "$LOG_FILE"
  
  # Test authentication by running a simple command
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Testing authentication with simple command" | tee -a "$LOG_FILE"
  if claude -p "test" --cwd "$HOME" 2>&1 | tee -a "$LOG_FILE" | grep -q "test"; then
    echo "✅ Authentication successful"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Authentication test passed" | tee -a "$LOG_FILE"
  else
    echo "⚠️ Authentication test failed, but continuing (may need manual login)"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Authentication test failed" | tee -a "$LOG_FILE"
  fi
else
  echo "ℹ️ No CLAUDE_INSTALL_TOKEN found - manual login required"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] No CLAUDE_INSTALL_TOKEN environment variable" | tee -a "$LOG_FILE"
fi

# Setup default preferences - remove the editor config since it's not essential for automation
echo "⚙️ Claude Code setup complete"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skipping editor configuration (not essential for automation)" | tee -a "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Claude Code installation process complete" | tee -a "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log file available at: $LOG_FILE" | tee -a "$LOG_FILE"