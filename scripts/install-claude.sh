#!/usr/bin/env bash
set -e

echo "Setting up Claude Code..."

# Install Claude Code if not already present
if ! command -v claude >/dev/null 2>&1; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  
  # Add ~/.local/bin to PATH if not already there
  if [[ -f ~/.bashrc ]] && ! grep -q '.local/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "Added ~/.local/bin to PATH in .bashrc"
  fi
  
  # Set PATH for current session
  export PATH="$HOME/.local/bin:$PATH"
  echo "PATH updated for current session"
else
  echo "Claude Code already installed"
fi

# Only create config if we have the required secrets
if [[ -n "${CLAUDE_USER_ID:-}" && -n "${CLAUDE_ACCOUNT_UUID:-}" && -n "${CLAUDE_ORG_UUID:-}" ]]; then
  CLAUDE_CONFIG_FILE="$HOME/.claude.json"
  echo "Creating Claude configuration with environment variables..."
  
  # Generate current timestamps
  CURRENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
  
  cat > "$CLAUDE_CONFIG_FILE" << EOF
{
  "numStartups": 1,
  "installMethod": "native",
  "autoUpdates": false,
  "theme": "light",
  "customApiKeyResponses": {
    "approved": [],
    "rejected": []
  },
  "tipsHistory": {},
  "cachedStatsigGates": {
    "tengu_disable_bypass_permissions_mode": false
  },
  "firstStartTime": "${CURRENT_TIME}",
  "userID": "${CLAUDE_USER_ID}",
  "projects": {},
  "autoUpdatesProtectedForNative": true,
  "oauthAccount": {
    "accountUuid": "${CLAUDE_ACCOUNT_UUID}",
    "emailAddress": "${CLAUDE_EMAIL}",
    "organizationUuid": "${CLAUDE_ORG_UUID}",
    "organizationRole": "admin",
    "workspaceRole": null,
    "organizationName": "${CLAUDE_EMAIL}'s Organization"
  },
  "claudeCodeFirstTokenDate": "${CURRENT_TIME}",
  "recommendedSubscription": "",
  "shiftEnterKeyBindingInstalled": true,
  "hasCompletedOnboarding": true,
  "lastOnboardingVersion": "1.0.110",
  "hasOpusPlanDefault": false,
  "subscriptionNoticeCount": 0,
  "hasAvailableSubscription": false,
  "hasIdeOnboardingBeenShown": {
    "vscode": true
  },
  "s1mAccessCache": {},
  "isQualifiedForDataSharing": false,
  "fallbackAvailableWarningThreshold": 0.5
}
EOF

  echo "✅ Claude configuration created with your account details and current timestamp"
  
  # Create credentials file if OAuth tokens are available
  if [[ -n "${CLAUDE_ACCESS_TOKEN:-}" && -n "${CLAUDE_REFRESH_TOKEN:-}" ]]; then
    CLAUDE_CREDS_DIR="$HOME/.claude"
    CLAUDE_CREDS_FILE="$CLAUDE_CREDS_DIR/.credentials.json"
    
    # Ensure .claude directory exists
    mkdir -p "$CLAUDE_CREDS_DIR"
    
    echo "Creating Claude credentials file..."
    cat > "$CLAUDE_CREDS_FILE" << EOF
{
  "claudeAiOauth": {
    "accessToken": "${CLAUDE_ACCESS_TOKEN}",
    "refreshToken": "${CLAUDE_REFRESH_TOKEN}",
    "expiresAt": 9999999999999,
    "scopes": ["user:inference", "user:profile"],
    "subscriptionType": "pro"
  }
}
EOF
    
    # Set restrictive permissions like the original
    chmod 600 "$CLAUDE_CREDS_FILE"
    echo "✅ Claude credentials created"
  else
    echo "⚠️  Missing OAuth token secrets - interactive mode will require manual login"
  fi
else
  echo "⚠️  Missing Claude environment variables - falling back to API key method"
fi

# Create settings file with plan mode as default and pre-approved commands
CLAUDE_SETTINGS_DIR="$HOME/.claude"
CLAUDE_SETTINGS_FILE="$CLAUDE_SETTINGS_DIR/settings.json"

mkdir -p "$CLAUDE_SETTINGS_DIR"
echo "Configuring Claude settings (plan mode default with pre-approved commands)..."

cat > "$CLAUDE_SETTINGS_FILE" << 'EOF'
{
  "permissions": {
    "defaultMode": "plan",
    "allow": [
      "Bash(git status:*)",
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(git branch:*)",
      "Bash(git remote:*)",
      "Bash(git config:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git show:*)",
      "Bash(git stash:*)",
      "Bash(git fetch:*)",
      "Bash(git pull:*)",
      "Bash(git checkout:*)",
      "Bash(git switch:*)",
      "Bash(git rev-list:*)",
      "Bash(git rev-parse:*)",
      "Bash(git ls-files:*)",
      "Bash(ls:*)",
      "Bash(pwd)",
      "Bash(chmod:*)",
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(python:*)",
      "Bash(python3:*)",
      "Bash(pip:*)",
      "Bash(pip3:*)",
      "Bash(export:*)",
      "Bash(curl:*)",
      "Bash(jq:*)",
      "Bash(cat:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(rm:*)",
      "Bash(touch:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(sort:*)",
      "Bash(grep:*)",
      "Bash(find:*)",
      "Bash(sed:*)",
      "Bash(awk:*)",
      "Bash(echo:*)",
      "Bash(which:*)",
      "Bash(whoami)",
      "Bash(env)",
      "Bash(date)",
      "Bash(gh:*)",
      "Bash(GH_TOKEN:*)",
      "Bash(claude:*)",
      "Bash(ip:*)",
      "Bash(journalctl:*)",
      "Bash(nc:*)",
      "Bash(sudo wg:*)",
      "Bash(sudo wg-quick:*)",
      "Bash(sudo apt-get:*)",
      "Bash(sudo ls:*)",
      "Bash(sudo cat:*)",
      "Bash(sudo test:*)",
      "Bash(sudo stat:*)",
      "Bash(sudo mkdir:*)",
      "Bash(sudo tee:*)",
      "Bash(sudo chown:*)",
      "Bash(sudo chmod:*)",
      "Read(*)",
      "Read(//home/codespace/.claude/**)"
    ]
  },
  "includeCoAuthoredBy": false
}
EOF

echo "✅ Claude settings configured"

# Fallback to API key method
if [[ -n "${CLAUDE_INSTALL_TOKEN:-}" ]]; then
  echo "Configuring API key authentication..."
  if [[ -f ~/.bashrc ]] && ! grep -q "ANTHROPIC_API_KEY" ~/.bashrc; then
    echo "export ANTHROPIC_API_KEY=\"$CLAUDE_INSTALL_TOKEN\"" >> ~/.bashrc
    echo "API key configured"
  fi
fi

# Build and install custom skills
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_SCRIPT="$SCRIPT_DIR/build-commands.sh"

# Build skill definitions from markdown files if build script exists
if [[ -f "$BUILD_SCRIPT" ]]; then
  echo "Building custom skills from markdown files..."
  bash "$BUILD_SCRIPT"
fi

echo "🎉 Claude Code setup complete"
echo "You should be able to run 'claude' immediately without login!"