#!/usr/bin/env bash
set -e

echo "Setting up Claude Code..."

# Install Claude Code if not already present
if ! command -v claude >/dev/null 2>&1; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude Code already installed"
fi

# Set up authentication if token is available
if [[ -n "${CLAUDE_INSTALL_TOKEN:-}" ]]; then
  echo "Configuring authentication..."
  
  # Add API key to shell profile for persistence
  if [[ -f ~/.bashrc ]] && ! grep -q "ANTHROPIC_API_KEY" ~/.bashrc; then
    echo "export ANTHROPIC_API_KEY=\"$CLAUDE_INSTALL_TOKEN\"" >> ~/.bashrc
    echo "Authentication configured - will be available in new shell sessions"
  else
    echo "Authentication already configured"
  fi
else
  echo "No CLAUDE_INSTALL_TOKEN found - manual login required"
fi

echo "Claude Code setup complete"
echo "Open a new terminal to use Claude Code, or run: source ~/.bashrc"