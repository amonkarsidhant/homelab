#!/usr/bin/env bash
set -euo pipefail

echo "=== Tailscale VPN Setup ==="
echo ""
echo "This script installs Tailscale on this VM and generates setup commands for your Pi and Mac."
echo ""

# Install Tailscale on VM
if ! command -v tailscale &>/dev/null; then
  echo "[1/3] Installing Tailscale on this VM..."
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "[1/3] Tailscale already installed on VM"
fi

echo ""
echo "[2/3] To connect this VM to Tailscale, run:"
echo "  sudo tailscale up --accept-routes"
echo ""
echo "You will need to authenticate. Copy the URL below:"
timeout 10 tailscale up --qr || true
echo ""

echo "[3/3] --- PI SETUP (run on your Raspberry Pi) ---"
echo "  curl -fsSL https://tailscale.com/install.sh | sh"
echo "  sudo tailscale up --accept-routes"
echo "  tailscale ip -4"
echo ""
echo "--- MAC SETUP (run on your MacBook) ---"
echo "  brew install tailscale"
echo "  tailscale up --accept-routes"
echo "  tailscale ip -4"
echo ""
echo "Once all devices are on Tailscale, add their Tailscale IPs to:"
echo "  ~/.config/homelab/backup.env"
echo "  Example:"
echo "    DEST_PI=100.x.x.x:/path/to/backups"
echo "    DEST_MAC=100.x.x.x:/path/to/backups"
