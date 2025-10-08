#!/usr/bin/env bash
set -Eeuo pipefail

# Install MCP (Model Context Protocol) servers for Claude Code
# Logs to /tmp/dotfiles-install.log
#
# IMPORTANT: When using Puppeteer in GitHub Codespaces:
# - Always use http://localhost (not the Codespace URL) to avoid authentication redirects
# - Apache runs locally on port 80 within the Codespace
# - The Codespace URL requires GitHub authentication and won't work with Puppeteer

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a /tmp/dotfiles-install.log
}

log "Starting MCP server installation..."

# Verify Claude Code is installed
if ! command -v claude &> /dev/null; then
    log "ERROR: Claude Code is not installed. Please run install-claude.sh first."
    exit 1
fi

# Verify Node.js and npm are installed (required for Puppeteer MCP)
if ! command -v node &> /dev/null; then
    log "Node.js not found. Installing Node.js via nvm..."

    # Install nvm if not present
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    # Install latest LTS version of Node.js
    nvm install --lts
    nvm use --lts
fi

if ! command -v npm &> /dev/null; then
    log "ERROR: npm is not available. Cannot install MCP servers."
    exit 1
fi

log "Node.js version: $(node --version)"
log "npm version: $(npm --version)"

# Install Chrome dependencies for Puppeteer (required for headless browser)
log "Installing Chrome dependencies for Puppeteer..."
if sudo apt-get update && sudo apt-get install -y \
    ca-certificates \           # SSL/TLS certificates for HTTPS connections
    libatk-bridge2.0-0 \        # Accessibility toolkit bridge for assistive technologies
    libatk1.0-0 \               # Accessibility toolkit for UI components
    libcups2 \                  # Common UNIX Printing System for print functionality
    libdrm2 \                   # Direct Rendering Manager for GPU access
    libxkbcommon0 \             # Keyboard handling library
    libxcomposite1 \            # X11 Composite extension for window compositing
    libxdamage1 \               # X11 Damage extension for tracking window changes
    libxfixes3 \                # X11 fixes extension for cursor and region support
    libxrandr2 \                # X11 RandR extension for screen resolution/rotation
    libgbm1 \                   # Generic Buffer Management for GPU buffer allocation
    libasound2 \                # ALSA sound library for audio support
    libnspr4 \                  # Netscape Portable Runtime for cross-platform support
    libnss3 \                   # Network Security Services for SSL/TLS
    libx11-xcb1 \               # X11 XCB (X protocol C-language Binding) bridge
    libxcb-dri3-0 \             # X11 DRI3 extension for direct rendering
    libxss1 \                   # X11 Screen Saver extension
    libxtst6 \                  # X11 XTEST extension for input event simulation
    fonts-liberation \          # Liberation fonts (Arial, Times New Roman substitutes)
    fonts-noto-color-emoji \    # Color emoji font support
    libappindicator3-1 \        # Application indicators for system tray
    libpango-1.0-0 \            # Text layout and rendering library
    libcairo2 2>&1 | tee -a /tmp/dotfiles-install.log; then  # 2D graphics library
    log "✓ Chrome dependencies installed successfully"
else
    log "WARNING: Failed to install some Chrome dependencies (may already be installed)"
fi

# Install Puppeteer locally for custom screenshot scripts
log "Installing Puppeteer in /tmp for custom scripts..."
if (cd /tmp && npm install puppeteer 2>&1 | tee -a /tmp/dotfiles-install.log); then
    log "✓ Puppeteer installed in /tmp/node_modules"
else
    log "WARNING: Failed to install Puppeteer (may already be installed)"
fi

# Add Puppeteer MCP server with Codespaces-compatible browser args
log "Adding Puppeteer MCP server..."
if claude mcp add-json "puppeteer" '{"command":"npx","args":["-y","@modelcontextprotocol/server-puppeteer"],"env":{"PUPPETEER_LAUNCH_OPTIONS":"{\"headless\":true,\"args\":[\"--no-sandbox\",\"--disable-setuid-sandbox\",\"--disable-dev-shm-usage\"]}"}}'; then
    log "✓ Puppeteer MCP server added successfully"
else
    log "WARNING: Failed to add Puppeteer MCP server (may already exist)"
fi

# List installed MCP servers
log "Installed MCP servers:"
claude mcp list 2>&1 | tee -a /tmp/dotfiles-install.log || log "Could not list MCP servers"

log "MCP server installation complete!"
log "You may need to restart Claude Code for changes to take effect."
