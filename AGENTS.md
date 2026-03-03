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
- `~/.claude/commands/*.md` - Installed skill definitions (copied from `commands/`)

## Custom Skills
Create skill definition at `commands/name.md` with prompt content. Filename becomes `/name` skill. First line = description, full content = prompt. Auto-installed during setup.

**Current:** `/browser`, `/commit`, `/consult`, `/doc-style`, `/echo`, `/echo-reflect`, `/my-skills`, `/pr-review`, `/save-context`, `/save-plan`, `/secrets`, `/wireguard`

## Writing Friction-Free Skill Commands

**Write commands so the first token matches an allow rule.** The allow list matches command prefixes — anything prepended (env vars, variable assignments) creates a new unmatched pattern. Export env vars first or ensure they're in `.bashrc` so bare commands match existing rules.

**Avoid shell expansion in commands.** `$()` and `${}` trigger safety prompts regardless of allow rules. Store secrets and config in ready-to-use format so manipulation isn't needed at call time.

**Don't use broad control-flow allow rules.** `Bash(for:*)` and `Bash(bash:*)` are unsafe — the prefix doesn't constrain what runs inside the loop or script. Use multiple individual Bash calls instead of loops, and reference specific script paths rather than allowing bare `bash`.

## Development
- Use `set -Eeuo pipefail`
- Log to `/tmp/dotfiles-install.log`
- Scripts must work non-interactively
- Support automated (secrets) and manual (login) flows
- Update PATH in session and `~/.bashrc`
- After any change to this repo, review `README.md` for accuracy and update it if needed (file list, skills list, scripts, etc.)
- Testing: Run `scripts/test.sh` to validate all scripts
