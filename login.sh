#!/bin/bash
echo ".........................................................."

# If tailscale is installed and connected, show its IPs
if command -v tailscale >/dev/null 2>&1; then
  echo "Tailscale IPs (IPv4 / IPv6):"
  tailscale ip -4 2>/dev/null || echo "  (no IPv4)"
  tailscale ip -6 2>/dev/null || echo "  (no IPv6)"
  echo ""

  # Optional: show short status (first few lines)
  echo "Tailscale status (short):"
  tailscale status --short 2>/dev/null | sed -n '1,6p'
  echo ""
else
  echo "tailscale: غير مثبت أو ليس في PATH."
fi

echo "Username: runneradmin"
echo "Password: P@ssw0rd!"
echo ".........................................................."#!/bin/bash
echo ".........................................................."

# If tailscale is installed and connected, show its IPs
if command -v tailscale >/dev/null 2>&1; then
  echo "Tailscale IPs (IPv4 / IPv6):"
  tailscale ip -4 2>/dev/null || echo "  (no IPv4)"
  tailscale ip -6 2>/dev/null || echo "  (no IPv6)"
  echo ""

  # Optional: show short status (first few lines)
  echo "Tailscale status (short):"
  tailscale status --short 2>/dev/null | sed -n '1,6p'
  echo ""
else
  echo "tailscale: not installed on PATH."
fi

echo "Username: runneradmin"
echo "Password: P@ssw0rd!"
echo ".........................................................."
