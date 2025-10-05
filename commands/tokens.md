---
description: Display Claude access and refresh tokens for GitHub Secrets
---

Read both the access token and refresh token from ~/.claude/.credentials.json and display them in this format:

CLAUDE_ACCESS_TOKEN:
[access token value]

CLAUDE_REFRESH_TOKEN:
[refresh token value]

This format makes it easy to copy each token individually when updating GitHub Codespaces secrets at https://github.com/settings/codespaces.
