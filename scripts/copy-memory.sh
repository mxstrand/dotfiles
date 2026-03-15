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

# Find the project root by looking for .git
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -z "$PROJECT_ROOT" ]]; then
  exit 0
fi

DEST_DIR="$PROJECT_ROOT/.claude-docs/memory"
mkdir -p "$DEST_DIR"

FILENAME=$(basename "$FILE_PATH")
cp "$FILE_PATH" "$DEST_DIR/$FILENAME"
echo "Copied memory file to $DEST_DIR/$FILENAME"
