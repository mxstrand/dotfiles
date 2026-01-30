Enable browser automation with Puppeteer MCP server

Set up and use browser automation capabilities for local development. This enables:
- Website navigation and screenshot capture
- Web page interaction (clicking, form filling, scrolling)
- Frontend testing and debugging
- Web scraping and data extraction
- Visual regression testing

## Installation

If Puppeteer MCP server is not yet installed, run the installation script below. Otherwise, skip directly to using the browser automation tools.

Installation script:
```bash
#!/usr/bin/env bash
set -Eeuo pipefail

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
    ca-certificates \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxss1 \
    libxtst6 \
    fonts-liberation \
    fonts-noto-color-emoji \
    libappindicator3-1 \
    libpango-1.0-0 \
    libcairo2 2>&1 | tee -a /tmp/dotfiles-install.log; then
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
```

## Usage Guidelines

**CRITICAL - GitHub Codespaces URLs:**
- Always use `http://localhost` (NOT the Codespace forwarded URL)
- The Codespace public URL requires GitHub authentication and will fail with Puppeteer
- Apache/nginx runs locally on port 80 within the Codespace
- Example: `http://localhost:3000` (correct) vs `https://xyz-3000.preview.app.github.dev` (will fail)

**Screenshot Best Practices:**
- Save all screenshots to `.claude-docs/` directory as PNG files
- Use Node.js scripts in `/tmp` (where Puppeteer is pre-installed)
- Example pattern: `.claude-docs/screenshot-$(date +%s).png`

**Common Use Cases:**
1. **Visual Testing**: Capture screenshots of UI components at different viewport sizes
2. **Web Scraping**: Extract data from tables, lists, or dynamic content
3. **Form Testing**: Automate form filling and submission workflows
4. **Navigation Testing**: Test multi-page flows and user journeys
5. **Debugging**: Capture state of application at specific breakpoints

After installation (or if already installed), verify the setup works and assist with the user's browser automation task.
