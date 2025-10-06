Install MCP Puppeteer server for browser automation

Install and configure the Puppeteer MCP server to enable browser automation capabilities. This allows Claude to:
- Navigate websites and take screenshots
- Interact with web pages (click, fill forms, etc.)
- Test and debug frontend applications
- Extract data from web pages

Run the installation script at `/workspaces/dotfiles/scripts/install-mcp.sh` and verify the setup is complete. After installation, test basic functionality by using Puppeteer to visit example.com and take a screenshot to confirm it works.

**IMPORTANT**: When taking screenshots, always save them to `.claude-docs/` directory as PNG files using Node.js scripts in `/tmp` (where puppeteer is pre-installed).
