# Dotfiles Repository

Automated Claude Code setup for GitHub Codespaces with OAuth or API key authentication.

## Files
- `install.sh` - Main entry, orchestrates setup
- `scripts/install-claude.sh` - Claude installer with dual auth modes
- `scripts/build-commands.sh` - Builds commands.json from markdown
- `commands/*.md` - Command prompts (filename = command name)

## Authentication
**OAuth**: Requires 6 secrets: `CLAUDE_USER_ID`, `CLAUDE_ACCOUNT_UUID`, `CLAUDE_ORG_UUID`, `CLAUDE_EMAIL`, `CLAUDE_ACCESS_TOKEN`, `CLAUDE_REFRESH_TOKEN`
**API Key**: Requires `CLAUDE_INSTALL_TOKEN`

## Configuration
- `~/.claude.json` - User/org config
- `~/.claude/.credentials.json` - OAuth tokens (chmod 600)
- `~/.claude/settings.json` - Settings (plan mode default)
- `~/.claude/commands.json` - Custom slash commands

## Custom Commands
Create `commands/name.md` with prompt content. Filename becomes `/name` command. First line = description, full content = prompt. Auto-installed during setup.

**Current:** `/docs`, `/save`, `/token`

## Development
- Use `set -e` or `set -Eeuo pipefail`
- Log to `/tmp/dotfiles-install.log`
- Scripts must work non-interactively
- Support automated (secrets) and manual (login) flows
- Update PATH in session and `~/.bashrc`

- **Testing**: Run `scripts/test.sh` to validate all scripts
