# dotfiles

Personal dotfiles for automated development environment setup in GitHub Codespaces.

## What's included

- **[Claude Code](https://www.anthropic.com/claude-code)** - AI-powered development assistant
- Automated installation and optional authentication scripts with error handling
- Custom slash commands built from markdown files
- Plan mode enabled by default

## Files

- `install.sh` - Main setup script
- `scripts/install-claude.sh` - Claude Code installer with verification and authentication
- `scripts/build-commands.sh` - Builds custom commands from markdown files
- `scripts/test.sh` - Test suite for verifying setup
- `commands/` - Markdown files defining custom slash commands

## Setup

To use these dotfiles with GitHub Codespaces, follow the [official dotfiles setup guide](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles).

### Authentication

- **Manual Login (Default):** No secrets required - login interactively each time you start a new Codespace
- **Automated Login (Optional):** Configure [Codespace secrets](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces) to skip manual login:

  1. **First, login manually once** to capture your authentication details
  2. **Extract the required values** from your local Claude configuration files:

     From `~/.claude.json`:
     ```bash
     cat ~/.claude.json | jq -r '.userID'           # CLAUDE_USER_ID
     cat ~/.claude.json | jq -r '.oauthAccount.accountUuid'     # CLAUDE_ACCOUNT_UUID
     cat ~/.claude.json | jq -r '.oauthAccount.organizationUuid' # CLAUDE_ORG_UUID
     cat ~/.claude.json | jq -r '.oauthAccount.emailAddress'     # CLAUDE_EMAIL
     ```

     From `~/.claude/.credentials.json`:
     ```bash
     cat ~/.claude/.credentials.json | jq -r '.claudeAiOauth.accessToken'  # CLAUDE_ACCESS_TOKEN
     cat ~/.claude/.credentials.json | jq -r '.claudeAiOauth.refreshToken' # CLAUDE_REFRESH_TOKEN
     ```

  3. **Set these as Codespace secrets:**
     - `CLAUDE_USER_ID` - Your Claude user ID
     - `CLAUDE_ACCOUNT_UUID` - Your Claude account UUID
     - `CLAUDE_ORG_UUID` - Your Claude organization UUID
     - `CLAUDE_EMAIL` - Your Claude email address
     - `CLAUDE_ACCESS_TOKEN` - OAuth access token (enables automatic login)
     - `CLAUDE_REFRESH_TOKEN` - OAuth refresh token (enables automatic login)

> [!NOTE]
> Access and refresh tokens may expire and require manual regeneration and updating.

## Custom Commands

Add custom slash commands by creating markdown files in `commands/`:

```bash
# Example: commands/mycommand.md
echo "Your custom prompt here" > commands/mycommand.md
./scripts/build-commands.sh  # Regenerate commands.json
```

**Built-in commands:**
- `/docs` - Read and summarize documentation in /docs directory
- `/save` - Save conversation as markdown plan for next agent
- `/token` - Output access token and copy to clipboard

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
