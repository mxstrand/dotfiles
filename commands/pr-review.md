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

**Auth:** The default codespace token only has permissions on the current repo. `GH_TOKEN` is set automatically to `MIKE_CODESPACE_TOKEN` in this environment — all `gh` commands will use it. If `gh auth status` shows missing scopes, run `/secrets` first.

## Step 2: List Open PRs

Fetch all open PRs on the target repo authored by you:

```bash
gh pr list --repo {owner}/{repo} --state open --author @me --json number,title,url,comments,reviews,isDraft,reviewDecision,headRefName
```

Compute a combined activity count for display: `(.comments | length) + (.reviews | length)`. This covers both conversation-level comments and code reviews (which carry inline comments). Note: `comments` alone misses inline review comments — always include `reviews`.

Display a numbered list:
```
Open PRs on {owner}/{repo} (authored by you):

  1. #42  Add user authentication  [3 comments]
  2. #38  Fix null pointer in checkout  [0 comments]  (draft)
  3. #35  Refactor API layer  [1 review]
```

Mark drafts, note activity counts. Ask: *"Which PR would you like to review? (enter number or PR #)"*

## Step 3: Check Out the PR Branch Locally

Before fetching comments, check out the selected PR branch so files can be read locally for context.

**First, check for uncommitted local changes:**
```bash
git status --short
```

If there are unstaged or staged changes, ask the user:
*"You have uncommitted changes. Stash them before checking out the PR branch? (yes / no)"*

- If yes: `git stash push -m "pre-pr-review stash"`
- If no: proceed (checkout may fail if there are conflicts — warn the user)

**Then check out the PR branch:**
```bash
gh pr checkout {number}
```

Confirm which branch was checked out.

## Step 4: Fetch All Comments

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
  --jq '[.reviews[] | select(.body | length > 0)]'
```

## Step 5: Identify Unresolved Threads

Group inline comments into threads using `in_reply_to_id` (root comments have none). A thread is **resolved** if:
- The PR author replied with: "done", "fixed", "addressed", "resolved", "updated", "will do", or similar
- A reviewer replied with: "thanks", "lgtm", "looks good", or similar sign-off

Focus only on **unresolved** threads. If all threads are resolved, say so clearly and stop.

## Step 6: Classify Commenters

- **Bot** (e.g., Copilot, CI bots): login ends in `[bot]` → label as `@{login} (bot)`
- **Human**: all others → label as `@{login}`

## Step 7: Read Relevant Files for Context

Before producing the action plan, read the local files referenced in unresolved comments. Use the checked-out branch files to understand the current code and make concrete, accurate recommendations.

## Step 8: Produce the Action Plan

Output the plan header:

---

## PR Review Action Plan

**PR:** #{number} — {title}
**URL:** {url}
**Repo:** {owner}/{repo}
**Branch:** {headRefName} (checked out locally)
**Commenters:** {e.g., "3 threads from @copilot[bot] (bot), 1 from @teammate"}
**Unresolved threads:** {N}

---

Then present each unresolved thread as a card, ordered high → low priority. Use this format for each:

---

**Thread {n}** | {priority emoji} {Priority} | `{file}:{line}` | {commenter}

**Reviewer comment:**
> {full verbatim comment text}

**Recommendation:** {concrete description of what to change and why}

**Draft reply:**
> {exact reply text that will be posted on your behalf}

**How to apply:** {e.g., "Amend commit `abc1234`" or "`fixup!` targeting commit `def5678`"}

---


After all cards, include the standard sections:

### Recommended Changes — Subsequent PR

*Valid feedback, but out of scope for this PR. Address in a follow-up.*

| Priority | Commenter | Topic | Recommended Change |
|----------|-----------|-------|--------------------|

### No Action Needed

*Informational, already addressed, or not applicable.*

| Commenter | Comment Summary | Reason |
|-----------|-----------------|--------|

---

## Priority Definitions

- 🔴 **Critical** — Bug, security issue, broken functionality; must fix before merge
- 🟠 **High** — Correctness concern, missing error handling, API contract violation
- 🟡 **Medium** — Code quality, maintainability, consistency with codebase patterns
- 🟢 **Low** — Style, naming, minor suggestions, nitpicks

## Commit Strategy

Strong preference for **revising existing commits** over adding new incremental ones:

- **`git commit --amend`** — Best for the most recent commit, or use interactive rebase (`git rebase -i`) to amend an earlier one. Use when the fix is small and directly corrects a mistake in that commit.
- **`fixup!` commit** — Best when commits are already pushed or the change is substantive. Create with `git commit -m "fixup! {original message}"` then squash with `git rebase --autosquash` before merge.
- **New standalone commit** — Only when the change is genuinely additive and doesn't correct an existing commit (rare for PR review fixes).

---

## Step 9: Implement and Respond

After the user approves the plan and any implementation is done, handle each actionable thread:

1. **Post the reply** using the REST API:
   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
     --method POST --field body="{reply text}"
   ```

2. **Ask separately whether to resolve the thread:**
   *"Reply posted. Also resolve this thread? (yes / no)"*

   If yes, resolve via GraphQL:
   - First fetch the thread node ID:
     ```bash
     gh api graphql -f query='{
       repository(owner: "{owner}", name: "{repo}") {
         pullRequest(number: {number}) {
           reviewThreads(first: 50) {
             nodes { id isResolved comments(first: 1) { nodes { databaseId } } }
           }
         }
       }
     }'
     ```
   - Then resolve:
     ```bash
     gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "{threadId}"}) { thread { isResolved } } }'
     ```

Handle each thread one at a time so the user can decide per-thread.

---

## Step 10: Save the Plan

After presenting the plan, ask: *"Shall I save this plan to `.claude-docs/plans/`?"*

If approved, save to:
```
.claude-docs/plans/YYYY-MM-DD-pr-{number}-{slugified-title}.md
```

Use today's date. Slugify the title (lowercase, hyphens, no special chars, max 40 chars).

Confirm the saved path once written. Remind the user: *"Saved locally. You can also push to https://github.com/mxstrand/claude-plans for cross-Codespace persistence."*
