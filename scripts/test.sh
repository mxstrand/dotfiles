#!/usr/bin/env bash
set -Eeuo pipefail

echo "🧪 Testing dotfiles setup..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_SCRIPT="$SCRIPT_DIR/install-claude.sh"

cd "$REPO_DIR"

FAILURES=0
fail() { echo "   ❌ $1"; FAILURES=$((FAILURES + 1)); }
pass() { echo "   ✅ $1"; }

# Extract the settings.json embedded in the install-claude.sh heredoc so we can
# validate it without running the installer.
extract_settings() {
  sed -n '/^cat > "\$CLAUDE_SETTINGS_FILE" << .EOF.$/,/^EOF$/p' "$CLAUDE_SCRIPT" | sed '1d;$d'
}

# Test 1: All shell scripts parse (syntax check)
echo "1️⃣ Checking shell script syntax..."
for sh in "$REPO_DIR"/install.sh "$SCRIPT_DIR"/*.sh; do
  [[ -f "$sh" ]] || continue
  if bash -n "$sh" 2>/dev/null; then
    pass "$(basename "$sh") parses"
  else
    fail "$(basename "$sh") has a syntax error"
  fi
done

# Test 2: Install script exists
echo "2️⃣ Checking install-claude.sh path..."
if [[ -f "$CLAUDE_SCRIPT" ]]; then
  pass "install-claude.sh found"
else
  fail "install-claude.sh not found"
fi

# Test 3: Embedded settings.json is valid JSON
echo "3️⃣ Validating embedded settings.json..."
SETTINGS_JSON="$(extract_settings)"
if [[ -n "$SETTINGS_JSON" ]] && jq empty <<<"$SETTINGS_JSON" 2>/dev/null; then
  pass "embedded settings.json is valid JSON"
else
  fail "embedded settings.json is missing or malformed"
  SETTINGS_JSON=""
fi

# Test 4: Hook scripts referenced by settings.json exist in the repo
echo "4️⃣ Checking hook scripts exist..."
if [[ -n "$SETTINGS_JSON" ]]; then
  HOOK_SCRIPTS="$(jq -r '.hooks | to_entries[].value[].hooks[].command' <<<"$SETTINGS_JSON" \
    | grep -oP '[\w-]+\.sh' | sort -u)"
  while read -r hook; do
    [[ -n "$hook" ]] || continue
    if [[ -f "$SCRIPT_DIR/$hook" ]]; then
      pass "hook $hook present"
    else
      fail "hook $hook referenced by settings.json but missing from scripts/"
    fi
  done <<<"$HOOK_SCRIPTS"
else
  echo "   ⚠️  Skipped (settings.json unavailable)"
fi

# Test 5: enabledPlugins ↔ CLAUDE_PLUGINS are consistent
echo "5️⃣ Checking plugin config consistency..."
if [[ -n "$SETTINGS_JSON" ]]; then
  ENABLED="$(jq -r '.enabledPlugins // {} | keys[]' <<<"$SETTINGS_JSON" | sort)"
  INSTALLED="$(sed -n '/declare -A CLAUDE_PLUGINS=(/,/^)/p' "$CLAUDE_SCRIPT" \
    | grep -oP '(?<=\[")[^"]+(?="\])' | sort)"
  if [[ "$ENABLED" == "$INSTALLED" ]]; then
    count=$(grep -c . <<<"$ENABLED" || true)
    pass "enabledPlugins and CLAUDE_PLUGINS agree ($count plugin(s))"
  else
    fail "mismatch between enabledPlugins and CLAUDE_PLUGINS:"
    echo "      enabledPlugins : $(tr '\n' ' ' <<<"$ENABLED")"
    echo "      CLAUDE_PLUGINS : $(tr '\n' ' ' <<<"$INSTALLED")"
  fi
else
  echo "   ⚠️  Skipped (settings.json unavailable)"
fi

# Test 6: Installed settings.json (if a real install has run) is valid JSON
echo "6️⃣ Validating installed settings.json (if present)..."
SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS" ]]; then
  if jq empty "$SETTINGS" 2>/dev/null; then
    pass "$SETTINGS is valid JSON"
  else
    fail "$SETTINGS is malformed"
  fi
else
  echo "   ⚠️  Skipped (not installed yet — run ./install.sh)"
fi

echo ""
if [[ "$FAILURES" -eq 0 ]]; then
  echo "✅ All tests passed!"
else
  echo "❌ $FAILURES test(s) failed."
  exit 1
fi

echo ""
echo "To fully test installation, run: ./install.sh"
