---
description: Fetch and triage PR review comments into a prioritized action plan
---

Interactively select an open pull request, fetch all unresolved review comments, and produce a structured action plan. The plan is discussion-first — present it for review and discussion before any implementation begins.

## Step 1: Detect Remotes and Target Repo

Run `git remote -v` to identify available remotes.

- Prefer **`upstream`** — the canonical repo in a forked workflow where PRs are submitted
- Fall back to **`origin`** if no upstream exists
- If multiple remotes exist, note which one is being used

Extract the GitHub `owner/repo` from the remote URL (handle both HTTPS `https://github.com/owner/repo.git` and SSH `git@github.com:owner/repo.git` formats).

## Step 2: List Open PRs

Fetch all open PRs on the target repo authored by you:

```bash
gh pr list --repo {owner}/{repo} --state open --author @me --json number,title,url,comments,isDraft,reviewDecision,headRefName
```

Display a numbered list:
```
Open PRs on {owner}/{repo} (authored by you):

  1. #42  Add user authentication  [3 comments]
  2. #38  Fix null pointer in checkout  [0 comments]  (draft)
  3. #35  Refactor API layer  [1 comment]
```

Mark drafts, note comment counts (zero-comment PRs are less likely to need review but include them). Ask: *"Which PR would you like to review? (enter number or PR #)"*

## Step 3: Fetch All Comments

For the selected PR, run these commands:

**Inline review comments** (code-level, with file/line context):
```bash
gh api "repos/{owner}/{repo}/pulls/{number}/comments" --paginate \
  --jq '[.[] | {id, body, path, line: (.line // .original_line), user: .user.login, created_at, in_reply_to_id}]'
```

**General PR comments** (conversation):
```bash
gh api "repos/{owner}/{repo}/issues/{number}/comments" --paginate \
  --jq '[.[] | {id, body, user: .user.login, created_at}]'
```

**Review summaries** (Approve/Request Changes with body text):
```bash
gh pr view {number} --repo {owner}/{repo} --json reviews \
  --jq '.reviews[] | select(.body != "") | {state, body, author: .author.login, submittedAt}'
```

## Step 4: Identify Unresolved Threads

Group inline comments into threads using `in_reply_to_id` (root comments have none). A thread is **resolved** if:
- The PR author replied with: "done", "fixed", "addressed", "resolved", "updated", "will do", or similar
- A reviewer replied with: "thanks", "lgtm", "looks good", or similar sign-off

Focus only on **unresolved** threads. If all threads are resolved, say so clearly and stop.

## Step 5: Classify Commenters

- **Bot** (e.g., Copilot, CI bots): login ends in `[bot]` → label as `@{login} (bot)`
- **Human**: all others → label as `@{login}`

## Step 6: Produce the Action Plan

Output the plan in this structure:

---

## PR Review Action Plan

**PR:** #{number} — {title}
**URL:** {url}
**Repo:** {owner}/{repo}
**Commenters:** {e.g., "3 threads from @copilot[bot] (bot), 1 from @teammate"}
**Unresolved threads:** {N}

---

### 1. Recommended Changes — Current PR

*Address these before merging. Ordered high → low priority.*
*Default approach: revise existing commits (amend or fixup) rather than adding new incremental commits.*

| Priority | File:Line | Commenter | Issue | Recommended Change | How to Apply |
|----------|-----------|-----------|-------|--------------------|--------------|
| 🔴 Critical | `src/foo.ts:42` | @copilot[bot] (bot) | Missing null check | Add guard before dereferencing `user` | Amend commit `abc1234` |
| 🟠 High | `api/auth.ts:88` | @teammate | Returns 500 on invalid token | Return 401 with error body | `fixup!` targeting commit `def5678` |
| 🟡 Medium | ... | ... | ... | ... | ... |
| 🟢 Low | ... | ... | ... | ... | ... |

---

### 2. Recommended Changes — Subsequent PR

*Valid feedback, but out of scope for this PR. Address in a follow-up.*

| Priority | Commenter | Topic | Recommended Change |
|----------|-----------|-------|--------------------|
| 🟡 Medium | @teammate | Auth module growing large | Extract token logic to `auth/token.ts` |

---

### 3. No Action Needed

*Informational, already addressed, or not applicable.*

| Commenter | Comment Summary | Reason |
|-----------|-----------------|--------|
| @copilot[bot] (bot) | Add JSDoc to `getUser()` | Already documented in module README |
| @teammate | Why use X here? | Answered in thread — no code change needed |

---

## Priority Definitions

- 🔴 **Critical** — Bug, security issue, broken functionality; must fix before merge
- 🟠 **High** — Correctness concern, missing error handling, API contract violation
- 🟡 **Medium** — Code quality, maintainability, consistency with codebase patterns
- 🟢 **Low** — Style, naming, minor suggestions, nitpicks

## How to Apply (Commit Strategy)

Strong preference for **revising existing commits** over adding new incremental ones:

- **`git commit --amend`** — Best for the most recent commit, or use interactive rebase (`git rebase -i`) to amend an earlier one. Use when the fix is small and directly corrects a mistake in that commit.
- **`fixup!` commit** — Best when commits are already pushed or the change is substantive. Create with `git commit -m "fixup! {original message}"` then squash with `git rebase --autosquash` before merge.
- **New standalone commit** — Only when the change is genuinely additive and doesn't correct an existing commit (rare for PR review fixes).

---

## Step 7: Save the Plan

After presenting the plan, ask: *"Shall I save this plan to `.claude-docs/plans/`?"*

If approved, save to:
```
.claude-docs/plans/YYYY-MM-DD-pr-{number}-{slugified-title}.md
```

Use today's date. Slugify the title (lowercase, hyphens, no special chars, max 40 chars).

Confirm the saved path once written. Remind the user: *"Saved locally. You can also push to https://github.com/mxstrand/claude-plans for cross-Codespace persistence."*
