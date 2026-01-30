# dotfiles

Personal dotfiles for automated development environment setup in GitHub Codespaces.

## What's included

- **[Claude Code](https://www.anthropic.com/claude-code)** - AI-powered development assistant
- **MCP Server Support** - Puppeteer for browser automation (screenshots, web scraping, testing)
- Automated installation and optional authentication scripts with error handling
- Custom slash commands built from markdown files
- Plan mode enabled by default
- `.claude-docs/` directory for Claude-accessible scripts and documentation

## Files

- `install.sh` - Main setup script, creates `.claude-docs/` directories
- `scripts/install-claude.sh` - Claude Code installer with verification and authentication
- `scripts/install-mcp.sh` - MCP server installer for Puppeteer browser automation
- `scripts/build-commands.sh` - Builds custom commands from markdown files
- `scripts/test.sh` - Test suite for verifying setup
- `commands/` - Markdown files defining custom slash commands
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

## Custom Commands

Add custom slash commands by creating markdown files in `commands/`:

```bash
# Example: commands/mycommand.md
echo "Your custom prompt here" > commands/mycommand.md
./scripts/build-commands.sh  # Regenerate commands.json
```

**Built-in commands:**
- `/docs` - Read and summarize documentation in /docs directory
- `/save` - Save conversation as markdown plan for future reference
- `/endplan` - Save agreed plan to .claude-docs
- `/commit` - Propose atomic commits for review before pushing
- `/browser` - Enable browser automation with Puppeteer MCP server
- `/secrets` - Display available GitHub secrets and capabilities
- `/doc-style` - Apply user's documentation preferences

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
