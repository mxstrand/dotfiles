#!/usr/bin/env bash
set -Eeuo pipefail

echo "🧪 Testing dotfiles setup..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REPO_DIR"

# Test 1: Build skills
echo "1️⃣ Testing skill builder..."
./scripts/build-commands.sh
COMMANDS_DIR="$HOME/.claude/commands"
COPIED=$(ls "$COMMANDS_DIR"/*.md 2>/dev/null | wc -l)
if [[ "$COPIED" -gt 0 ]]; then
  echo "   ✅ Skills built successfully ($COPIED .md files)"
else
  echo "   ❌ No skill files found in $COMMANDS_DIR"
  exit 1
fi

# Test 2: Check skill count matches source
echo "2️⃣ Checking skill count..."
CMD_COUNT=$(ls commands/*.md | wc -l)
if [[ "$CMD_COUNT" -eq "$COPIED" ]]; then
  echo "   ✅ All $CMD_COUNT skills copied"
else
  echo "   ❌ Mismatch: $CMD_COUNT source .md files but $COPIED copied"
  exit 1
fi

# Test 3: Check each skill has valid frontmatter (two --- fences)
echo "3️⃣ Validating skill frontmatter..."
INVALID=0
for md_file in commands/*.md; do
  fence_count=$(grep -c '^---$' "$md_file" 2>/dev/null || true)
  if [[ "$fence_count" -lt 2 ]]; then
    echo "   ❌ $(basename "$md_file"): missing frontmatter fences (found $fence_count)"
    INVALID=$((INVALID + 1))
  fi
done
if [[ "$INVALID" -eq 0 ]]; then
  echo "   ✅ All skills have valid frontmatter"
else
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

# Test 6: Validate settings.json is well-formed
echo "6️⃣ Validating settings.json..."
SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
  if jq empty "$SETTINGS" 2>/dev/null; then
    echo "   ✅ settings.json is valid JSON"
  else
    echo "   ❌ settings.json is malformed"
    exit 1
  fi
else
  echo "   ⚠️  settings.json not found (run install first)"
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "To fully test installation, run: ./install.sh"
