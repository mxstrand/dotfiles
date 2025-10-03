#!/usr/bin/env bash
set -e

# Build commands.json from markdown files in commands/ directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$REPO_DIR/commands"
OUTPUT_FILE="$REPO_DIR/claude-commands.json"

if [[ ! -d "$COMMANDS_DIR" ]]; then
  echo "Error: commands directory not found"
  exit 1
fi

# Start JSON object
echo "{" > "$OUTPUT_FILE"

first=true
for md_file in "$COMMANDS_DIR"/*.md; do
  if [[ -f "$md_file" ]]; then
    # Extract command name from filename (without .md extension)
    cmd_name=$(basename "$md_file" .md)

    # Read the markdown file content
    prompt=$(cat "$md_file")

    # Create description from first line or command name
    description=$(echo "$prompt" | head -n 1 | cut -c 1-60)
    if [[ ${#description} -eq 60 ]]; then
      description="${description}..."
    fi

    # Add comma if not first entry
    if [[ "$first" = false ]]; then
      echo "," >> "$OUTPUT_FILE"
    fi
    first=false

    # Write JSON entry (properly escaped)
    cat >> "$OUTPUT_FILE" << EOF
  "$cmd_name": {
    "description": "$description",
    "prompt": $(echo "$prompt" | jq -Rs .)
  }
EOF
  fi
done

# Close JSON object
echo "}" >> "$OUTPUT_FILE"

echo "✅ Built $OUTPUT_FILE from markdown files in $COMMANDS_DIR"
