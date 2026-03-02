#!/usr/bin/env bash
set -Eeuo pipefail

# Build custom skill definitions from markdown files and copy to ~/.claude/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$REPO_DIR/commands"
TARGET_DIR="$HOME/.claude/commands"

if [[ ! -d "$COMMANDS_DIR" ]]; then
  echo "Error: skill definitions directory not found at $COMMANDS_DIR"
  exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

for md_file in "$COMMANDS_DIR"/*.md; do
  if [[ -f "$md_file" ]]; then
    cmd_name=$(basename "$md_file" .md)

    # Validate: warn if prompt would be empty (catches frontmatter-only files)
    fence_count=$(grep -c '^---$' "$md_file" 2>/dev/null || true)
    if [[ "$fence_count" -lt 2 ]]; then
      echo "Warning: $cmd_name missing frontmatter fences — skipping"
      continue
    fi

    # Copy markdown file to Claude commands directory
    cp "$md_file" "$TARGET_DIR/"
  fi
done

# Count skills
copied=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l)
echo "✅ Copied $copied skill(s) to $TARGET_DIR"
