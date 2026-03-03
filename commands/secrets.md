---
description: Configure GitHub token and display capabilities
---

Check for `MIKE_CODESPACE_TOKEN` (user's personal token with gist+repo permissions), configure it for use, and summarize available operations.

## Tasks

1. **Set up and verify in a single command** — run this exact Bash call (starting with `export` so it is pre-approved):
   ```
   export GH_TOKEN="$MIKE_CODESPACE_TOKEN" && grep -q 'MIKE_CODESPACE_TOKEN' ~/.bashrc || echo 'export GH_TOKEN="${MIKE_CODESPACE_TOKEN:-$GH_TOKEN}"' >> ~/.bashrc && gh auth status && gh gist list --limit 3
   ```
   - This exports GH_TOKEN for the current session AND persists it to `.bashrc` for all future shells
   - If output shows `(GH_TOKEN)` with `gist` and `repo` scopes, the personal token is active
   - If not, warn that gist/multi-repo operations may not work

2. **Summarize what you can do:**
   Based on detected scopes, confirm you can:
   - ✅ Create/update gists (secret or public)
   - ✅ Read/write across user's repositories
   - ✅ Create issues and PRs
   - ✅ Manage repository content

3. **Set up for session:**
   - Confirm `GH_TOKEN` is active for the current session and persisted to `.bashrc`
   - Confirm ready to use for gist/repo operations
   - Provide example: "Want me to create a gist? Just ask!"

## Cross-Repo Auth Cheatsheet

The default codespace `GITHUB_TOKEN` only has permissions on the current repo. All operations targeting upstream repos, other user repos, or org repos require `MIKE_CODESPACE_TOKEN`. Use these patterns from the start to avoid auth failures:

**PRs on upstream repos from a fork:**
```bash
gh pr create \
  --repo {upstream-owner}/{repo} \
  --head {fork-owner}:{branch-name} \
  --base main \
  --title "..." --body "..."
```

**Pushing to repos outside the current codespace:**
```bash
# Set the remote URL with the token before pushing:
git remote set-url origin "https://x-access-token:${MIKE_CODESPACE_TOKEN}@github.com/{owner}/{repo}.git"
git push
```

**All `gh` API/CLI calls to external repos:**
```bash
gh api repos/{owner}/{repo}/...
gh pr list --repo {owner}/{repo}
```

**Security Note:** Never display actual token values - only scopes and capabilities.
