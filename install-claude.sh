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
  fi
  
  # Set for current session and test
  export ANTHROPIC_API_KEY="$CLAUDE_INSTALL_TOKEN"
  
  if claude -p "Ready!" >/dev/null 2>&1; then
    echo "Authentication successful"
  else
    echo "Authentication test failed - manual login may be required"
  fi
else
  echo "No CLAUDE_INSTALL_TOKEN found - manual login required"
fi

echo "Claude Code setup complete"
echo ""
echo "To use Claude Code in the current terminal, reload your shell profile with:  source ~/.bashrc"
echo ""
read -p "Would you like me to reload your shell profile now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Reloading shell..."
    exec bash
else
    echo "No problem! Just run 'source ~/.bashrc' or open a new terminal when ready."
fi