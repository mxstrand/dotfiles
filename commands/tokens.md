---
description: Display Claude access and refresh tokens for GitHub Secrets (project, gitignored)
---

First, determine the actual home directory path by running `echo $HOME` using the Bash tool.

Then, read the configuration files at `$HOME/.claude.json` and `$HOME/.claude/.credentials.json` using the actual path returned from the previous step.

If either file doesn't exist, inform the user that they need to authenticate with Claude Code first (either via `claude login` for OAuth or by setting `CLAUDE_INSTALL_TOKEN` for API key auth).

Display the values in this format:

CLAUDE_USER_ID:
[value from .userID]

CLAUDE_ACCOUNT_UUID:
[value from .oauthAccount.accountUuid]

CLAUDE_ORG_UUID:
[value from .oauthAccount.organizationUuid]

CLAUDE_EMAIL:
[value from .oauthAccount.emailAddress]

CLAUDE_ACCESS_TOKEN:
[value from .claudeAiOauth.accessToken]

CLAUDE_REFRESH_TOKEN:
[value from .claudeAiOauth.refreshToken]

This format makes it easy to copy each value individually when setting up GitHub Codespaces secrets at https://github.com/settings/codespaces.
