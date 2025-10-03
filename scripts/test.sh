#!/usr/bin/env bash
set -e

echo "🧪 Testing dotfiles setup..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REPO_DIR"

# Test 1: Build commands
echo "1️⃣ Testing command builder..."
./scripts/build-commands.sh
if [[ -f claude-commands.json ]]; then
  echo "   ✅ Commands built successfully"
else
  echo "   ❌ Failed to build commands"
  exit 1
fi

# Test 2: Verify JSON is valid
echo "2️⃣ Validating JSON structure..."
if jq empty claude-commands.json 2>/dev/null; then
  echo "   ✅ Valid JSON"
else
  echo "   ❌ Invalid JSON"
  exit 1
fi

# Test 3: Check command count
echo "3️⃣ Checking commands..."
CMD_COUNT=$(ls commands/*.md | wc -l)
JSON_COUNT=$(jq 'keys | length' claude-commands.json)
if [[ "$CMD_COUNT" -eq "$JSON_COUNT" ]]; then
  echo "   ✅ All $CMD_COUNT commands generated"
else
  echo "   ❌ Mismatch: $CMD_COUNT .md files but $JSON_COUNT JSON entries"
  exit 1
fi

# Test 4: Check installation script exists
echo "4️⃣ Testing installation script paths..."
if [[ -f "$REPO_DIR/scripts/install-claude.sh" ]]; then
  echo "   ✅ Installation script found at correct path"
else
  echo "   ❌ Installation script not found"
  exit 1
fi

# Test 5: Check build script exists
if [[ -f "$REPO_DIR/scripts/build-commands.sh" ]]; then
  echo "   ✅ Build script accessible from install script"
else
  echo "   ❌ Build script not found"
  exit 1
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "To fully test installation, run: ./install.sh"
