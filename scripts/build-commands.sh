#!/usr/bin/env bash
set -e

# Copy markdown commands to ~/.claude/commands/ directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$REPO_DIR/commands"
TARGET_DIR="$HOME/.claude/commands"

if [[ ! -d "$COMMANDS_DIR" ]]; then
  echo "Error: commands directory not found at $COMMANDS_DIR"
  exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy all markdown files
copied=0
for md_file in "$COMMANDS_DIR"/*.md; do
  if [[ -f "$md_file" ]]; then
    cp "$md_file" "$TARGET_DIR/"
    copied=$((copied + 1))
  fi
done

echo "✅ Copied $copied command(s) to $TARGET_DIR"
