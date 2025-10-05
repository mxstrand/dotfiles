---
description: Propose atomic commits for review before pushing
---

First, analyze the current branch state and format the output with clear sections:

### Branch Information
- Current: [branch name]
- Remote(s): [list all remotes with URLs]

### Sync Status
- Status with origin/main (and upstream/main if exists)
- Commits ahead/behind for each remote
- ⚠️ Warning if working from an outdated main branch

Then analyze all uncommitted changes and propose well-structured, atomic commits.

## Proposed Commit Plan

For each proposed commit:
- **Files:** [list of files]
- **Message:** [conventional commit format message]
- **Rationale:** [explanation for grouping these changes]

Use blank lines between sections for readability on CLI.

Present the commit plan and ask for approval before proceeding. Once approved:
1. Create each commit in the proposed order
2. Show a summary of created commits
3. Ask if the user wants to push to remote

Follow conventional commit format (feat:, fix:, refactor:, chore:, docs:, etc.) and keep messages focused on the "why" rather than the "what".
