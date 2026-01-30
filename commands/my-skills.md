---
description: List custom skills available
---

Display all custom skills from the user's dotfiles repository.

## Tasks

1. **Find the skills:**
   - Installed skills are at `~/.claude/commands/` (directory name kept for CLI compatibility)
   - Source repository: `https://github.com/mxstrand/dotfiles` in the `commands/` directory

2. **List each skill:**
   - Read each `.md` file from `~/.claude/commands/`
   - Extract description from frontmatter (`description:` field) or first line
   - Format alphabetically as: **`/skill-name`** - Description

3. **Explain the setup:**
   - These skills are defined in the `mxstrand/dotfiles` repository
   - They're auto-installed in every Codespace via dotfiles setup
   - Skills are built from markdown files at: `https://github.com/mxstrand/dotfiles/tree/main/commands`

4. **Enable modifications:**
   - If `/secrets` has been run and MIKE_CODESPACE_TOKEN is configured, you can modify these skills
   - To add/edit skills: update files in `mxstrand/dotfiles` repo, `commands/` directory
   - Changes will appear in future Codespaces after dotfiles setup runs

**Format:**

## Your Custom Skills

**`/command-name`** - Description

---

**Source:** https://github.com/mxstrand/dotfiles (commands/ directory - kept for CLI compatibility)

**Modify them?** If you've run `/secrets`, I can edit the dotfiles repo to add or modify skills.
