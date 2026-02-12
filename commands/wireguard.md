---
description: Manage WireGuard VPN connection
---

Manage WireGuard VPN for secure network access in GitHub Codespaces. VPN is installed and configured automatically, but does **NOT** auto-connect. Use this skill to connect on-demand when you need VPN access.

## Tasks

1. **Check VPN connection status:**
   ```bash
   # Show active connections and peer information
   sudo wg show

   # Check if wg0 interface is up
   ip link show wg0

   # Display detailed peer information
   sudo wg show wg0
   ```

   **Status indicators:**
   - If output shows peer + latest handshake: ✅ **Connected**
   - If "Unable to access interface": ❌ **Not connected**
   - If "Device does not exist": ❌ **Not connected**
   - Handshake should update periodically if active (check PersistentKeepalive setting)

2. **Connect/Disconnect VPN:**
   ```bash
   # Connect to VPN
   sudo wg-quick up wg0

   # Disconnect from VPN
   sudo wg-quick down wg0

   # Restart VPN connection (if having issues)
   sudo wg-quick down wg0 && sudo wg-quick up wg0
   ```

   **When to connect:**
   - Only connect when you need access to VPN-protected resources
   - Conserves resources - only connect when actively needed
   - Safe to disconnect when done

3. **Troubleshooting:**
   ```bash
   # View recent logs
   journalctl -u wg-quick@wg0 -n 50 --no-pager

   # Check configuration file exists and is readable
   sudo ls -la /etc/wireguard/wg0.conf

   # Verify WireGuard tools are installed
   which wg wg-quick ip

   # Check network interface details
   ip addr show wg0

   # Check routing table
   ip route show

   # Test basic connectivity (use TCP, not ping - ICMP is blocked by VPN server)
   curl -I https://example.com
   ```

4. **Common Issues:**

   **"RTNETLINK answers: Operation not permitted"**
   - Missing `sudo` in command - WireGuard requires root privileges

   **"Unable to modify interface: No such device"**
   - Interface not created - check config file syntax
   - Verify: `sudo cat /etc/wireguard/wg0.conf` (should show valid config)

   **"Name or service not known"**
   - DNS resolution issue for VPN endpoint
   - Verify endpoint address in config file

   **"Handshake never updates"**
   - Network connectivity issue - check firewall or peer public key
   - Verify peer configuration matches server settings

   **"Config file not found"**
   - `WIREGUARD_CONFIG` secret may be missing or empty
   - Add secret at: https://github.com/settings/codespaces
   - Rebuild Codespace after adding secret

   **"ping shows 100% packet loss to VPN hosts"**
   - This is **expected** - ICMP is blocked by server policy, not a connectivity issue
   - Use TCP-based checks instead: `curl -I <url>` or `nc -zv <host> <port>`

## Configuration

**Codespace Secret Required:** `WIREGUARD_CONFIG`

**Format:** Standard WireGuard configuration file (INI format):
```ini
[Interface]
PrivateKey = <your-private-key>
Address = 10.x.x.x/24
DNS = 1.1.1.1

[Peer]
PublicKey = <server-public-key>
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

**Where to add secret:**
- Navigate to: GitHub → Settings → Codespaces → Secrets
- Click "New secret"
- Name: `WIREGUARD_CONFIG`
- Value: Paste your complete WireGuard configuration file
- Scope: User-level (recommended) or per-repository

**Security:**
- Config stored at `/etc/wireguard/wg0.conf` with `chmod 600` (owner read/write only)
- Private key never logged or displayed
- Follows same security patterns as Claude credentials

## Connection Behavior

WireGuard is **installed and configured automatically** during Codespace creation, but does **NOT** auto-connect.

**To connect:**
1. Type `/wireguard` in Claude Code
2. Ask Claude to connect to the VPN
3. Claude will run: `sudo wg-quick up wg0`
4. Verify connection with: `sudo wg show`

**To disconnect:**
1. Ask Claude to disconnect from the VPN
2. Claude will run: `sudo wg-quick down wg0`

**When to connect:**
- When you need access to VPN-protected resources
- Only connect when actively needed to conserve resources
- Safe to disconnect when done working with VPN resources

After running any VPN commands, always summarize the current connection status, peer information, and latest handshake time (if connected).
