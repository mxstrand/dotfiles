---
description: Configure GitHub token and display capabilities
---

Check for `MIKE_CODESPACE_TOKEN` (user's personal token with gist+repo permissions), configure it for use, and summarize available operations.

## Tasks

1. **Check for MIKE_CODESPACE_TOKEN:**
   - This is the expected Codespace secret with `gist` and `repo` scopes
   - If found, export it as `GH_TOKEN` so `gh` CLI uses it by default
   - If not found, warn that gist/multi-repo operations won't work

2. **Test capabilities with the token:**
   - Run `GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh auth status` to show scopes
   - Verify gist access: `GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh gist list --limit 3`
   - Display authenticated user and available scopes

3. **Summarize what you can do:**
   Based on detected scopes, confirm you can:
   - ✅ Create/update gists (secret or public)
   - ✅ Read/write across user's repositories
   - ✅ Create issues and PRs
   - ✅ Manage repository content

4. **Set up for session:**
   - Export `GH_TOKEN="$MIKE_CODESPACE_TOKEN"` for the current session
   - Confirm ready to use for gist/repo operations
   - Provide example: "Want me to create a gist? Just ask!"

**Security Note:** Never display actual token values - only scopes and capabilities.
