---
description: Apply user's documentation preferences
---

When writing documentation:

**Format**: Always use Markdown

**Code samples**: Depends on document type.

- Implementation plans (proposals, migration plans, task plans): include code blocks where they add confidence in the approach — before/after examples, conversion patterns, shell commands. Code in plans is the spec; it helps human reviewers evaluate whether the approach will work.
- Project documentation (architecture guidance, patterns, principles, general how-tos): exclude code blocks. Focus on explaining reasoning, purpose, and concepts. Reference specific files using `file:line` format if precision is needed.

**Formatting**: Use bold sparingly. No bold prefixes in lists unless requested.

**Tables**: Always pad columns with spaces so they are evenly aligned and human-readable in plain/unformatted view. Every column should be as wide as its widest cell.

**Sources**: Include markdown links for external references.