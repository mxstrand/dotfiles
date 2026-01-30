---
description: Save session context for handoff to next agent
---

Save a context handoff document to `.claude-docs/context/YYYY-MM-DD-[brief-topic].md` in current working directory. This creates a checkpoint so the next Claude session can pick up where you left off.

## Filename Generation

- Use brief, descriptive topics related to current work (e.g., "auth-implementation", "bug-investigation", "api-refactor")
- Format: `YYYY-MM-DD-[topic].md`

## Document Structure

Create a handoff document with:

- **Repository**: [current repo name/path]
- **Date**: YYYY-MM-DD
- **Session Summary**: What was accomplished in this session
- **Current State**: Where the work stands now
  - What's completed
  - What's in progress
  - Key files modified and their current state
- **Next Steps**: What needs to happen next (ordered list)
- **Key Findings/Decisions**: Important discoveries or choices made
- **Blockers/Questions**: Any open issues or uncertainties
- **File References**: List of relevant files with line numbers where applicable

Keep it concise but complete enough for the next agent to understand the full context and continue seamlessly.

## After Saving

Remind the user: "Context saved locally. The next Claude session can read this to continue where we left off. You can also save to https://github.com/mxstrand/claude-plans for cross-Codespace persistence if desired."
