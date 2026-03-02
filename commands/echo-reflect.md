---
description: Reflect this session's insights into your echo
---

Analyze how echo patterns influenced this session, then identify new or refined patterns. Produces two artifacts: a usage report and (optionally) updated pattern entries.

## Phase 1: Usage Report

### Step 1.1: Fetch Current Echo

Check for required secrets. If either is missing, stop with a clear message:
- `ECHO_REPO` — the echo repository (e.g. `owner/repo`)
- `MIKE_CODESPACE_TOKEN` — GitHub token with repo access

List existing pattern files:
```bash
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns \
  --jq '[.[] | {name: .name, sha: .sha}]' 2>/dev/null
```

Then fetch and read each file's content. If the API returns an error (directory doesn't exist), treat existing patterns as empty — do not use `||` fallback syntax.

### Step 1.2: Classify Each Pattern's Influence

For every loaded pattern, classify its role in this session using this taxonomy:

- **corrective** — the pattern prevented or corrected an error the agent was already making
- **generative** — the pattern shaped work proactively from the start
- **contextual** — the pattern applied but was modulated or overridden by specific context
- **dormant** — loaded but did not apply to this session's work

For each pattern, write a brief narrative (1-2 sentences) explaining how it influenced the work — or why it was dormant. This narrative is the human-readable layer; the classification is the machine-readable layer.

### Step 1.3: Write the Usage Report

Generate a usage report and write it to `$ECHO_REPO` at `usage/{date}-{slug}.md`.

**Anonymization rules:** Never reference specific repositories, organizations, businesses, product names, or other identifying information. Describe work generically: "port API endpoint to matching repo," not "port deletePicture to linkorb/userbase2."

**File format:**

The frontmatter contains only flat scalar fields. Per-pattern data lives in a fenced `yaml` code block in the body — this renders vertically on GitHub without horizontal scrolling, while remaining machine-parseable.

```markdown
---
id: usage-{YYYY-MM-DD}-{slug}
date: {YYYY-MM-DD}
task_summary: {one-line anonymized description of the session's work}
patterns_loaded: {N}
refinements_proposed: {N}
refinements_accepted: {N}
---

## Pattern Usage

\`\`\`yaml
patterns:
  - id: {pattern-id}
    influence: {corrective|generative|contextual|dormant}
    note: {optional — brief explanation, especially for corrective/contextual/dormant}

  - id: {pattern-id}
    influence: {influence-type}

  # ... all loaded patterns, separated by blank lines for readability
\`\`\`

## Usage Narrative

{Per-pattern narrative — how each pattern shaped (or didn't shape) the session's work. Group by influence type: corrective first, then generative, contextual, dormant. Use ### headings per group.}
```

**Write the file** — write content to a temp file first, then encode and push in one call. Capture the SHA from the response for the later frontmatter update:
```bash
printf '%s' '{full file content}' > /tmp/echo-usage.txt
USAGE_SHA=$(GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/usage/{filename}.md \
  --method PUT \
  --field message="usage: {slug}" \
  --field content="$(base64 -w0 /tmp/echo-usage.txt)" \
  --jq '.content.sha')
```

If the `usage/` directory does not yet exist, the GitHub API will create it automatically with the first file.

Confirm: `Usage report written to $ECHO_REPO/usage/{filename}.md`

---

## Phase 2: Pattern Reflection

### Step 2.1: Analyze the Session for Pattern Candidates

Using the usage analysis from Phase 1 as context:

**Scan for moments where AI agent behavior and actual needs diverged** — visible as a redirect, a reframing question, or a correction. These are the highest-value signals. For each, capture what the agent was doing (`from::`) and what the human moved toward instead (`to::`).

Patterns with **corrective** influence are strong refinement candidates — the agent needed correction, which may indicate the pattern's `when::` or `except::` clause is too narrow.

Patterns with **contextual** influence are candidates for `except::` refinements — the pattern applied but context overrode it.

Then look for any strong preferences that didn't surface as an explicit divergence — durable signals about how the human likes to work, think, or communicate.

Focus on signals likely to apply across many future sessions, not one-off task details.

### Step 2.2: Classify Against Existing Echo

For each candidate, compare against existing patterns and classify:
- **Duplicate** — already well-captured; skip
- **Refinement** — extends or sharpens an existing entry; propose an update
- **Net-new** — not yet in echo; propose as a new entry

### Step 2.3: Present for Review

Show only non-duplicate candidates, one at a time. Format each as a card:

---

**Candidate {n}** | {Net-new / Refinement} | `patterns/{id}.md`

**Title:** {present-tense truth statement}

**Description:** {one sentence, imperative voice directed at the agent: "[Do/Treat/Honor] [goal] because [underlying value]."}

**when::** {context in which this pattern applies}
**except::** {optional — situations where this pattern does not apply or should be suppressed}
**from::** {what the agent was doing when the divergence became visible}
**to::** {what the human moved toward instead}

{If Refinement — show the existing entry and the proposed change side by side}

*Add to echo? (yes / no / edit)*

---

Wait for user response before showing the next candidate. If the user says "edit", accept their revised wording before continuing.

If no candidates are found, say: `No new patterns or refinements identified this session.` and skip to confirmation.

### Writing Rules

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

### Step 2.4: Write Approved Entries to Echo

For each approved entry, create or update a file at `patterns/{id}.md` in `$ECHO_REPO`.

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

**Create the file using the GitHub Contents API** — write content to a temp file first, then encode and push in one call:
```bash
printf '%s' '{full file content}' > /tmp/echo-pattern.txt
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns/{id}.md \
  --method PUT \
  --field message="reflect: add {id}" \
  --field content="$(base64 -w0 /tmp/echo-pattern.txt)"
```

For **Refinements**, fetch the existing file's `sha` first, then update:
```bash
printf '%s' '{updated file content}' > /tmp/echo-pattern.txt
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns/{id}.md \
  --method PUT \
  --field message="reflect: refine {id}" \
  --field content="$(base64 -w0 /tmp/echo-pattern.txt)" \
  --field sha="{sha}"
```

---

## Confirmation

Summarize both phases:

```
Echo reflected.
- Usage report: $ECHO_REPO/usage/{filename}.md
- Patterns: {N} added, {N} refined, {N} skipped
```

Update the `refinements_proposed` and `refinements_accepted` counts in the usage report frontmatter to reflect the final outcome. Use `$USAGE_SHA` (captured in Step 1.3) as the `sha` field — the GitHub API requires it to update an existing file:
```bash
printf '%s' '{updated file content with final counts}' > /tmp/echo-usage-updated.txt
GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/usage/{filename}.md \
  --method PUT \
  --field message="usage: update counts for {slug}" \
  --field content="$(base64 -w0 /tmp/echo-usage-updated.txt)" \
  --field sha="$USAGE_SHA"
```