#!/usr/bin/env bash
set -Eeuo pipefail

# If already installed, bail out early
if command -v claude >/dev/null 2>&1; then
  echo "Claude Code is already installed"
  exit 0
fi

echo "Installing Claude Code..."
# Official installer (macOS/Linux/WSL)
if ! curl -fsSL https://claude.ai/install.sh | bash; then
  echo "❌ Claude Code installation failed (installer returned non-zero)"
  exit 1
fi

# Verify installation
if command -v claude >/dev/null 2>&1; then
  echo "✅ Claude Code installed successfully"
else
  echo "❌ Claude Code installation failed (binary not on PATH)"
  echo "   Try opening a new shell or ensure the installer's bin dir is on PATH."
  exit 1
fi

# Setup authentication if token is available
if [[ -n "${CLAUDE_INSTALL_TOKEN:-}" ]]; then
  echo "🔐 Setting up Claude authentication..."
  claude auth login --token "$CLAUDE_INSTALL_TOKEN"
else
  echo "ℹ️  No CLAUDE_INSTALL_TOKEN found - manual login required"
fi

# Setup default preferences
echo "⚙️ Configuring Claude preferences..."
claude config set editor "code" 2>/dev/null || true