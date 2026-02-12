# dotfiles

Personal dotfiles for automated development environment setup in GitHub Codespaces.

## What's included

- **[Claude Code](https://www.anthropic.com/claude-code)** - AI-powered development assistant
- **MCP Server Support** - Puppeteer for browser automation (screenshots, web scraping, testing)
- **WireGuard VPN** - On-demand VPN access from Codespaces (requires `WIREGUARD_CONFIG` secret)
- Automated installation and optional authentication scripts with error handling
- Custom skills built from markdown files
- Plan mode enabled by default
- `.claude-docs/` directory for Claude-accessible scripts and documentation

## Files

- `install.sh` - Main setup script, creates `.claude-docs/` directories
- `scripts/install-claude.sh` - Claude Code installer with verification and authentication
- `scripts/install-mcp.sh` - MCP server installer for Puppeteer browser automation
- `scripts/install-wireguard.sh` - WireGuard VPN installer, loads config from Codespace secret
- `scripts/build-commands.sh` - Builds custom skill definitions from markdown files
- `scripts/test.sh` - Test suite for verifying setup
- `commands/` - Skill definition files (directory name kept for CLI compatibility)
- `.claude-docs/` - Git-ignored directory for Claude-generated documentation and plans

## Setup

To use these dotfiles with GitHub Codespaces, follow the [official dotfiles setup guide](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles).

### Authentication

**Manual Login (Recommended)**

No setup required - just run `claude` and login when prompted. Takes ~30 seconds per new Codespace.

This is the simplest and most cost-effective approach, using your existing Claude.ai Pro subscription.

**Alternative: API Key**

For automated workflows or if you prefer zero-friction setup, set `ANTHROPIC_API_KEY` as a [Codespace secret](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces):
- Get your API key from https://console.anthropic.com/settings/keys
- Note: API usage is significantly more expensive than a Claude.ai Pro subscription for heavy use

## Custom Skills

Add custom skills by creating markdown files in `commands/`:

```bash
# Example: commands/myskill.md (directory named 'commands' for CLI compatibility)
echo "Your custom prompt here" > commands/myskill.md
./scripts/build-commands.sh  # Regenerate skill definitions
```

**Available skills:**
- `/browser` - Enable browser automation with Puppeteer MCP server
- `/commit` - Propose atomic commits for review before pushing
- `/doc-style` - Apply user's documentation preferences
- `/my-skills` - List all custom skills available in this setup
- `/save-context` - Save session context for handoff to next agent
- `/save-plan` - Save plan or design document
- `/secrets` - Configure GitHub token and display capabilities
- `/wireguard` - Manage WireGuard VPN connection

## Testing

```bash
./scripts/test.sh  # Run test suite
```

## Local Installation

```bash
git clone https://github.com/YOUR-USERNAME/dotfiles.git
cd dotfiles
./install.sh
```
