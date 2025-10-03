# Dotfiles Repository Context

## Purpose
Automated development environment setup for GitHub Codespaces. Installs and configures Claude Code with optional OAuth or API key authentication.

## Repository Structure
- `install.sh` - Main entry point, orchestrates setup
- `install-claude.sh` - Claude Code installer with dual auth modes
- `README.md` - User-facing documentation

## Key Patterns

### Error Handling
- Use `set -e` or `set -Eeuo pipefail` for bash scripts
- Log to `/tmp/dotfiles-install.log` for debugging
- Provide clear status messages with emoji indicators

### Authentication Methods
1. **OAuth (Interactive Mode)**: Requires 6 Codespace secrets (USER_ID, ACCOUNT_UUID, ORG_UUID, EMAIL, ACCESS_TOKEN, REFRESH_TOKEN)
2. **API Key (Chat Mode)**: Requires `CLAUDE_INSTALL_TOKEN` secret

### Configuration Files
- `~/.claude.json` - Main config with user/org details
- `~/.claude/.credentials.json` - OAuth tokens (chmod 600)
- Environment variables read from Codespace secrets

## Development Guidelines
- Scripts must work in non-interactive Codespace creation
- Support both automated (secrets) and manual (login) flows
- Use `2>&1` for output visibility during setup
- Add PATH modifications to both session and `~/.bashrc`
- Test with and without secrets configured
