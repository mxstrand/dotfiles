#!/usr/bin/env bash
set -e

echo "Setting up Claude Code..."

# Install Claude Code if not already present
if ! command -v claude >/dev/null 2>&1; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude Code already installed"
fi

# Only create config if we have the required secrets
if [[ -n "${CLAUDE_USER_ID:-}" && -n "${CLAUDE_ACCOUNT_UUID:-}" && -n "${CLAUDE_ORG_UUID:-}" ]]; then
  CLAUDE_CONFIG_FILE="$HOME/.claude.json"
  echo "Creating Claude configuration with environment variables..."
  
  cat > "$CLAUDE_CONFIG_FILE" << EOF
{
  "numStartups": 1,
  "installMethod": "native",
  "autoUpdates": false,
  "customApiKeyResponses": {
    "approved": [],
    "rejected": []
  },
  "tipsHistory": {},
  "cachedStatsigGates": {
    "tengu_disable_bypass_permissions_mode": false
  },
  "firstStartTime": "2025-08-27T18:02:53.254773Z",
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
  "claudeCodeFirstTokenDate": "2025-08-27T18:02:53.254773Z",
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

  echo "✅ Claude configuration created with your account details"
else
  echo "⚠️  Missing Claude environment variables - falling back to API key method"
fi

# Fallback to API key method
if [[ -n "${CLAUDE_INSTALL_TOKEN:-}" ]]; then
  echo "Configuring API key authentication..."
  if [[ -f ~/.bashrc ]] && ! grep -q "ANTHROPIC_API_KEY" ~/.bashrc; then
    echo "export ANTHROPIC_API_KEY=\"$CLAUDE_INSTALL_TOKEN\"" >> ~/.bashrc
    echo "API key configured"
  fi
fi

echo "🎉 Claude Code setup complete"
echo "You should be able to run 'claude' immediately without login!"