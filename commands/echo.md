---
description: Load your echo — personal working patterns and preferences into this session
---

Load the user's personal working patterns from the echo repo (`$ECHO_REPO`) and apply them to this session.

## Steps

1. **Check for required secrets.** If either is missing, stop with a clear message:
   - `ECHO_REPO` — the echo repository (e.g. `owner/repo`)
   - `MIKE_CODESPACE_TOKEN` — GitHub token with repo access

2. **List pattern files:**
   ```bash
   GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns \
     --jq '[.[] | .name]'
   ```
   If the directory doesn't exist or is empty, say: *"Your echo is empty — use /echo-reflect after a session to start building it."* and stop.

3. **Fetch each pattern file:**
   ```bash
   GH_TOKEN="$MIKE_CODESPACE_TOKEN" gh api repos/$ECHO_REPO/contents/patterns/{filename} \
     --jq '.content | @base64d'
   ```

4. **Parse each pattern.** Each file follows this structure:
   ```markdown
   ---
   id: kebab-case-id
   category: communication | workflow | tooling | ...
   strength: strong | tentative
   added: YYYY-MM-DD
   ---

   ## Title (present-tense truth statement)
   One sentence description in imperative voice directed at the agent: "[Do/Treat/Honor] [goal] because [underlying value]."

   when:: context in which this pattern applies
   except:: (optional) situations where this pattern does not apply or should be suppressed
   from:: what the agent was doing before the redirection
   to:: what the human redirected toward
   ```

5. **Confirm and apply.** Do not list every pattern back unless asked. Confirm with:
   ```
   Echo loaded. {N} pattern(s) active:
   - {title 1}
   - {title 2}
   ...
   Working in sync with your way. When I apply a pattern proactively, I will tag it inline as [echo:pattern-id] so you can see the system working.
   ```

6. **Apply patterns throughout the session** using these principles:

   - **Internalize the "because", not just the behavior.** Each pattern's description ends with an underlying value. That value is what to apply — it generalizes to situations the pattern never explicitly anticipated.

   - **Apply proactively, not reactively.** Patterns are a lens to work through from the start of every response, not triggers to watch for. Don't wait for the user to exhibit a behavior before honoring the pattern.

   - **Respect strength weighting.** `strong` patterns are default behavior — apply them without hesitation. `tentative` patterns are leanings — apply them unless context clearly suggests otherwise.

   - **Apply in spirit, not mechanically.** The goal is to work in the user's way, not to perform it. If a pattern says the user prefers iterative dialogue, actually engage as a thinking partner — don't just ask more questions.

   - **Signal proactive application with an inline tag.** When a pattern is the reason for a specific choice — not just loosely consistent with it — append `[echo:pattern-id]` inline at the point of that decision. Keep it brief; the goal is transparency so the user can see the system working. Do not signal when the user explicitly asked for the behaviour (that is reactive, not proactive), when the pattern is only tangentially relevant, or more than once per pattern per session unless it is shaping a distinctly different decision.

     Example: *"Structuring B, C, and D as independent PRs so all three can be reviewed in parallel once A merges. [echo:maximize-parallel-throughput]"*
