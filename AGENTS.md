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

**Current:** `/browser`, `/commit`, `/consult`, `/doc-style`, `/echo`, `/echo-reflect`, `/jira`, `/my-skills`, `/pr-review`, `/save-context`, `/save-plan`, `/secrets`, `/wireguard`

## External Service Credentials in Skills

Skills that call external APIs receive credentials via environment variables (Codespace secrets). The credential source is defined by each skill — skills document what they expect and how to set it up.

### Security Rule: Credentials Must Not Appear in Output

Claude reads tool output and will inadvertently log or repeat values it sees. **Credentials must never pass through stdout.** Specifically:

- Check that credentials are *present* without printing their values
- Never extract a secret to a variable that Claude reads, then re-uses in a command
- Prefer piping credentials directly into the tool that needs them

### Safe Pattern: Verify Without Revealing

Check structure/presence using a test that outputs a status word, not the value:

```bash
echo "$MY_SECRET" | jq -r 'if .token then "ok" else "missing" end'
```

Non-sensitive config (URLs, usernames) can be extracted and used normally.

### Safe Pattern: netrc for curl Auth

When authenticating with curl, write credentials to a temp netrc file (jq redirects to file, nothing goes to stdout) and point curl at it:

```bash
jq -r '"machine example.com\nlogin \(.email)\npassword \(.token)"' \
  <<< "$MY_SECRET" > /tmp/.svc-netrc
chmod 600 /tmp/.svc-netrc

curl -s --netrc-file /tmp/.svc-netrc "https://example.com/api/..."
```

Credentials go from env var → file → curl without ever passing through Claude's context.

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
