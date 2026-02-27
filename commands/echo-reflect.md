---
description: Reflect this session's insights into your echo
---

Analyze the current session, identify 2-3 dominant patterns, compare against existing echo entries, and write approved findings to the echo repo (`$ECHO_REPO`).

## Step 1: Fetch Current Echo

Check for required secrets. If either is missing, stop with a clear message:
- `ECHO_REPO` — the echo repository (e.g. `owner/repo`)
- `MIKE_CODESPACE_TOKEN` — GitHub token with repo access

List existing pattern files:
```bash
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns \
  --jq '[.[] | {name: .name, sha: .sha}]' 2>/dev/null || echo "[]"
```

Then fetch and read each file's content. If the `patterns/` directory doesn't exist, treat existing patterns as empty.

## Step 2: Analyze the Session

**Scan for redirection moments first** — places where the human steered the agent off its presented course. These are the highest-value signals. For each, capture what the agent was doing (`from::`) and what the human redirected toward (`to::`).

Then look for any strong preferences that didn't surface through redirection — durable signals about how the human likes to work, think, or communicate.

Focus on signals likely to apply across many future sessions, not one-off task details.

## Step 3: Classify Against Existing Echo

For each candidate, compare against existing patterns and classify:
- **Duplicate** — already well-captured; skip
- **Refinement** — extends or sharpens an existing entry; propose an update
- **Net-new** — not yet in echo; propose as a new entry

## Step 4: Present for Review

Show only non-duplicate candidates, one at a time. Format each as a card:

---

**Candidate {n}** | {Net-new / Refinement} | `patterns/{id}.md`

**Title:** {present-tense truth statement}

**Description:** {one sentence, imperative voice directed at the agent: "[Do/Treat/Honor] [goal] because [underlying value]."}

**when::** {context in which this pattern applies}
**except::** {optional — situations where this pattern does not apply or should be suppressed}
**from::** {what the agent was doing or presenting before the redirection}
**to::** {what the human redirected toward}

{If Refinement — show the existing entry and the proposed change side by side}

*Add to echo? (yes / no / edit)*

---

Wait for user response before showing the next candidate. If the user says "edit", accept their revised wording before continuing.

## Writing Rules

- **Title:** Present-tense truth statement, not a noun phrase.
  - ✅ `Names carry conceptual weight`
  - ❌ `Naming Precision Over Convenience`

- **Description:** One sentence, imperative voice directed at the agent, centers the goal or underlying value — not the observable behavior. Includes the "because":
  - ✅ `Treat naming as a conceptual act, because a well-chosen name does real cognitive work — clarifying thinking and shaping how something is understood before it's built.`
  - ❌ `You reject names that don't feel right.` ← second person, behavior not goal

- **when/from/to:** Concise labeled fields — one line each, no prose paragraphs.

- **All fields must generalize.** Describe behaviors meaningful in any future session, with no reference to specific artifacts, names, or events from the current session.
  - ✅ `agent presents functionally adequate options and moves toward selecting one`
  - ❌ `agent suggested "codex" and "playbook"`

## Step 5: Write Approved Entries to Echo

For each approved entry, create a new file at `patterns/{id}.md` in `$ECHO_REPO`.

**File content:**
```markdown
---
id: {kebab-case-id matching filename}
category: {communication | workflow | tooling | naming | process | ...}
strength: {strong | tentative}
added: {YYYY-MM-DD}
---

## {Title}
{Description sentence}

when:: {when this applies}
except:: {optional — when this pattern does not apply}
from:: {what the agent was doing before the redirection}
to:: {what the human redirected toward}
```

**Create the file using the GitHub Contents API:**
```bash
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns/{id}.md \
  --method PUT \
  --field message="reflect: add {id}" \
  --field content="$(printf '%s' '{full file content}' | base64 -w0)"
```

For **Refinements**, fetch the existing file's `sha` first, then update:
```bash
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns/{id}.md \
  --method PUT \
  --field message="reflect: refine {id}" \
  --field content="$(printf '%s' '{updated file content}' | base64 -w0)" \
  --field sha="{sha}"
```

Confirm with:
```
Echo updated. {N} entry(ies) written to $ECHO_REPO.
```
