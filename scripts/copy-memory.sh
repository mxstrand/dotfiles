#!/usr/bin/env bash
set -euo pipefail
# PostToolUse hook: copy memory files to .claude-docs/memory/ so they survive inspection
# and can be manually preserved across codespaces.
#
# Receives tool use JSON on stdin. Only acts on Write calls targeting the memory path.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only act on Write tool calls to memory paths
if [[ "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" != */.claude/projects/*/memory/* ]]; then
  exit 0
fi

# Derive project root from the slug in the memory path.
# Path format: ~/.claude/projects/{slug}/memory/{file}.md
# The slug is the project root with slashes replaced by dashes (e.g. -app for /app).
SLUG=$(echo "$FILE_PATH" | sed -n 's|.*/\.claude/projects/\([^/]*\)/memory/.*|\1|p')
if [[ -z "$SLUG" ]]; then
  exit 0
fi

# Convert slug back to path: -app -> /app, -workspaces-nebula -> /workspaces/nebula
PROJECT_ROOT=$(echo "$SLUG" | sed 's|^-|/|; s|-|/|g')
if [[ ! -d "$PROJECT_ROOT" ]]; then
  exit 0
fi

DEST_DIR="$PROJECT_ROOT/.claude-docs/memory"
mkdir -p "$DEST_DIR"

FILENAME=$(basename "$FILE_PATH")
cp "$FILE_PATH" "$DEST_DIR/$FILENAME"
echo "Copied memory file to $DEST_DIR/$FILENAME"
