#!/usr/bin/env bash
set -Eeuo pipefail

LOG_FILE="/tmp/dotfiles-install.log"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting WireGuard VPN setup..."

# Check if WireGuard already installed
if command -v wg &> /dev/null; then
  log "✓ WireGuard already installed ($(wg --version 2>&1 | head -n1))"

  # Check if config exists (use sudo to check root-owned file)
  if sudo test -f /etc/wireguard/wg0.conf; then
    CONFIG_SIZE=$(sudo stat -c%s /etc/wireguard/wg0.conf 2>/dev/null || echo "0")
    log "✓ Configuration file exists at /etc/wireguard/wg0.conf (${CONFIG_SIZE} bytes)"
    log "VPN is ready - use '/wireguard' skill to connect when needed"
  else
    log "⚠️  WireGuard installed but no configuration found"
  fi

  exit 0
fi

# Install WireGuard userspace tools
log "Installing WireGuard CLI tools..."

# Update package lists (allow-releaseinfo-change to handle repository changes)
log "Updating package lists..."
sudo apt-get update --allow-releaseinfo-change 2>&1 | tee -a "$LOG_FILE" || {
  log "WARNING: apt-get update had some issues, but continuing..."
}

# Install WireGuard tools
log "Installing wireguard-tools and iproute2..."
if sudo apt-get install -y --no-install-recommends wireguard-tools iproute2 2>&1 | tee -a "$LOG_FILE"; then
  log "✓ WireGuard installed successfully"
else
  log "ERROR: Failed to install WireGuard packages"
  exit 1
fi

# Verify installation
if command -v wg &> /dev/null && command -v wg-quick &> /dev/null && command -v ip &> /dev/null; then
  log "✓ WireGuard tools verified: wg, wg-quick, ip"
else
  log "ERROR: WireGuard installation incomplete - missing required tools"
  exit 1
fi

# Configure from Codespace secret (if available)
if [[ -n "${WIREGUARD_CONFIG:-}" ]]; then
  log "Loading WireGuard configuration from WIREGUARD_CONFIG secret..."

  # Create config directory
  sudo mkdir -p /etc/wireguard

  # Write config file (use printenv to preserve multi-line content with special characters)
  if printenv WIREGUARD_CONFIG | sudo tee /etc/wireguard/wg0.conf > /dev/null; then
    sudo chmod 600 /etc/wireguard/wg0.conf
    sudo chown root:root /etc/wireguard/wg0.conf

    # Verify config file was written correctly (use sudo to check root-owned file)
    if sudo test -f /etc/wireguard/wg0.conf; then
      CONFIG_SIZE=$(sudo stat -c%s /etc/wireguard/wg0.conf 2>/dev/null || echo "0")
      if [[ "$CONFIG_SIZE" -gt 10 ]]; then
        log "✓ Configuration file created at /etc/wireguard/wg0.conf (${CONFIG_SIZE} bytes, chmod 600)"
        log "✓ VPN is ready - use '/wireguard' skill to connect when needed"
        log "   Connect: sudo wg-quick up wg0"
        log "   Status:  sudo wg show"
      else
        log "ERROR: Configuration file is too small (${CONFIG_SIZE} bytes) - may be incomplete"
        exit 1
      fi
    else
      log "ERROR: Configuration file not created"
      exit 1
    fi
  else
    log "ERROR: Failed to write configuration file"
    exit 1
  fi
else
  log "⚠️  WIREGUARD_CONFIG secret not found"
  log "To use WireGuard VPN, add WIREGUARD_CONFIG as a Codespace secret"
  log "See: https://github.com/settings/codespaces"
  log ""
  log "Configuration format (standard WireGuard .conf file):"
  log "[Interface]"
  log "PrivateKey = <your-private-key>"
  log "Address = 10.x.x.x/24"
  log "DNS = 1.1.1.1"
  log ""
  log "[Peer]"
  log "PublicKey = <server-public-key>"
  log "Endpoint = vpn.example.com:51820"
  log "AllowedIPs = 0.0.0.0/0"
  log "PersistentKeepalive = 25"
fi

log "WireGuard setup complete (installation only - no auto-connect)"
log "Use '/wireguard' skill in Claude Code for VPN management"
