# Dotfiles Repository

Automated Claude Code setup for GitHub Codespaces with manual login or optional API key.

## Files
- `install.sh` - Main entry, orchestrates setup
- `scripts/install-claude.sh` - Claude installer with dual auth modes
- `scripts/install-wireguard.sh` - WireGuard VPN installer
- `scripts/build-commands.sh` - Builds skill definitions from markdown
- `commands/*.md` - Skill definitions (filename = skill name)

## Authentication
**Manual login** (default): Run `claude` and login interactively (~30 sec per new Codespace)
**API Key** (optional): Set `ANTHROPIC_API_KEY` secret for automated login (more expensive)

## Configuration
- `~/.claude.json` - User/org config
- `~/.claude/.credentials.json` - OAuth tokens (chmod 600)
- `~/.claude/settings.json` - Settings (plan mode default)
- `~/.claude/commands.json` - Custom skill definitions (file name kept for CLI compatibility)

## Custom Skills
Create skill definition at `commands/name.md` with prompt content. Filename becomes `/name` skill. First line = description, full content = prompt. Auto-installed during setup.

**Current:** `/browser`, `/commit`, `/doc-style`, `/my-skills`, `/save-context`, `/save-plan`, `/secrets`, `/wireguard`

## Development
- Use `set -e` or `set -Eeuo pipefail`
- Log to `/tmp/dotfiles-install.log`
- Scripts must work non-interactively
- Support automated (secrets) and manual (login) flows
- Update PATH in session and `~/.bashrc`

- **Testing**: Run `scripts/test.sh` to validate all scripts
