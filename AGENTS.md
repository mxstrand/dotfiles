# Dotfiles Repository

Automated Claude Code setup for GitHub Codespaces with manual login or optional API key.

## Files
- `install.sh` - Main entry, orchestrates setup
- `scripts/install-claude.sh` - Claude installer with dual auth modes
- `scripts/install-wireguard.sh` - WireGuard VPN installer

## Authentication
**Manual login** (default): Run `claude` and login interactively (~30 sec per new Codespace)
**API Key** (optional): Set `ANTHROPIC_API_KEY` secret for automated login (more expensive)

## Configuration
- `~/.claude.json` - User/org config
- `~/.claude/.credentials.json` - OAuth tokens (chmod 600)
- `~/.claude/settings.json` - Settings (plan mode default)
- `~/.claude/commands/*.md` - Skill definitions (symlinked from echo repo)

## Custom Skills
Skills are defined in the [echo repo](https://github.com/mxstrand/echo) under `commands/`. At install time, `install-claude.sh` clones echo to `~/.echo` and symlinks `~/.echo/commands/*.md` into `~/.claude/commands/`. Dotfiles has no knowledge of individual command names — it symlinks whatever echo provides.

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

Non-sensitive config (URLs, hostnames) can be extracted — but **any Bash call that references a secret variable has its entire output filtered**. To extract non-sensitive values, write to a file in one Bash call, then read the file in a separate Bash call:

```bash
# Call 1: write (output filtered, that's fine)
echo "$MY_SECRET" | jq -r '.url' > /tmp/.svc-url

# Call 2: read (separate call, no secret reference, output visible)
cat /tmp/.svc-url
```

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

**Prefer protocol-level batching over N individual calls.** When a protocol or API supports fetching multiple items in one request, use it. Examples: IMAP `UID FETCH uid1,uid2,uid3 (BODY.PEEK[HEADER.FIELDS (...)])` fetches many headers in one curl call; `gh repo clone` with `--depth 1` gets all files locally in one call instead of N API fetches. Individual calls avoid loops, but per-call overhead still compounds — batch at the protocol level first.

**Don't use broad control-flow allow rules.** `Bash(for:*)` and `Bash(bash:*)` are unsafe — the prefix doesn't constrain what runs inside the loop or script. Use multiple individual Bash calls instead of loops, and reference specific script paths rather than allowing bare `bash`.

## Development
- Use `set -Eeuo pipefail`
- Log to `/tmp/dotfiles-install.log`
- Scripts must work non-interactively
- Support automated (secrets) and manual (login) flows
- Update PATH in session and `~/.bashrc`
- After any change to this repo, review `README.md` for accuracy and update it if needed
- Testing: Run `scripts/test.sh` to validate all scripts
