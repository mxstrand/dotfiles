#!/usr/bin/env bash
set -e

# Build custom skill definitions from markdown files and copy to ~/.claude/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$REPO_DIR/commands"
TARGET_DIR="$HOME/.claude/commands"
JSON_OUTPUT="$HOME/.claude/commands.json"

if [[ ! -d "$COMMANDS_DIR" ]]; then
  echo "Error: skill definitions directory not found at $COMMANDS_DIR"
  exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Build JSON using jq for proper escaping
jq -n '{}' > "$JSON_OUTPUT"

for md_file in "$COMMANDS_DIR"/*.md; do
  if [[ -f "$md_file" ]]; then
    # Extract skill name from filename
    cmd_name=$(basename "$md_file" .md)

    # Extract description (value on same line as "description:")
    description=$(grep "^description:" "$md_file" | sed 's/^description: *//')

    # Extract prompt (everything after frontmatter, excluding description line)
    prompt=$(awk '/^---$/,/^---$/ {next} /^description:/ {next} {print}' "$md_file")

    # Add to JSON using jq
    tmp=$(mktemp)
    jq --arg name "$cmd_name" \
       --arg desc "$description" \
       --arg prompt "$prompt" \
       '.[$name] = {description: $desc, prompt: $prompt}' \
       "$JSON_OUTPUT" > "$tmp"
    mv "$tmp" "$JSON_OUTPUT"

    # Copy markdown file
    cp "$md_file" "$TARGET_DIR/"
  fi
done

# Count skills
copied=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l)
echo "✅ Copied $copied skill(s) to $TARGET_DIR"
