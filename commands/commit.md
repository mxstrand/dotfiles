---
description: Propose atomic commits for review before pushing
---

First, check the co-author settings and analyze the current branch state, formatting the output with clear sections:

### Co-Author Settings
Check if `git config trailer.coauthor.command` is set:
- If set: Display "Status: ✓ Enabled - Claude will be listed as co-author (Co-Authored-By: Claude <noreply@anthropic.com>)"
- If not set: Display "Status: ✗ Disabled - Claude will not be listed as co-author"

### Branch Information
- Current: [branch name]
- Remote(s): [list all remotes with URLs]

### Issue Number Detection
Extract issue/task number from branch name (look for numbers at the end, e.g., `feature-1234`, `bugfix/PROJ-1234`):
- If found: Display "Issue: #[number]"
- If not found: Ask "What issue/task number should be included in commits? (or 'none' to skip)"

Store the issue number for use in commit messages.

### Sync Status
- Status with origin/main (and upstream/main if exists)
- Commits ahead/behind for each remote
- ⚠️ Warning if working from an outdated main branch

Then analyze all uncommitted changes and propose well-structured, atomic commits.

## Proposed Commit Plan

For each proposed commit:
- **Files:** [list of files]
- **Message:** [conventional commit format message with #[issue] appended if issue number was provided]
- **Rationale:** [explanation for grouping these changes]

Use blank lines between sections for readability on CLI.

Present the commit plan and ask for approval before proceeding. Once approved:
1. Create each commit in the proposed order (appending #[issue] to each commit message if provided)
2. Show a summary of created commits
3. Ask if the user wants to push to remote

Follow conventional commit format (feat:, fix:, refactor:, chore:, docs:, etc.) and keep messages focused on the "why" rather than the "what". If an issue number was provided, append it as #[number] at the end of each commit message.
