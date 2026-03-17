# dotfiles

Personal dotfiles for automated development environment setup in GitHub Codespaces.

## What's included

- **[Claude Code](https://www.anthropic.com/claude-code)** - AI-powered development assistant
- **MCP Server Support** - Puppeteer for browser automation (screenshots, web scraping, testing)
- **WireGuard VPN** - On-demand VPN access from Codespaces (requires `WIREGUARD_CONFIG` secret)
- Automated installation and optional authentication scripts with error handling
- Custom skills symlinked from [echo](https://github.com/mxstrand/echo) repo
- Plan mode enabled by default
- `.claude-docs/` directory for Claude-accessible scripts and documentation

## Files

- `install.sh` - Main setup script, creates `.claude-docs/` directories
- `scripts/install-claude.sh` - Claude Code installer with verification and authentication
- `scripts/install-wireguard.sh` - WireGuard VPN installer, loads config from Codespace secret
- `scripts/check-permissions.sh` - Stop hook: surfaces local allow rules to promote to global
- `scripts/session-start.sh` - SessionStart hook: prompts Claude to offer `/echo` at session start
- `scripts/copy-memory.sh` - PostToolUse hook: copies memory files to `.claude-docs/memory/` for visibility
- `scripts/test.sh` - Test suite for verifying setup
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

Custom skills live in the [echo repo](https://github.com/mxstrand/echo) under `commands/`. At install time, dotfiles clones echo to `~/.echo` and symlinks command files into `~/.claude/commands/`.

**Requires:** `ECHO_REPO` codespace secret set to the echo repo clone URL (e.g., `https://github.com/mxstrand/echo`).

See the echo repo for the full list of available skills.

## Memory Persistence

Claude's memory files are ephemeral — they live in `~/.claude/projects/` and get destroyed with the codespace. To persist memories across codespaces:

1. A **PostToolUse hook** copies memory writes to `.claude-docs/memory/` in the project root for visibility
2. Review and commit keepers to the echo repo under `memories/`
3. At session start, echo's `/memories` command loads portable memories from `~/.echo/memories/` into the current project's Claude memory path and auto-generates the `MEMORY.md` index

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
