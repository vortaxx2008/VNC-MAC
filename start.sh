#!/bin/bash

# --- Download login.sh ---
curl -s -o login.sh -L "https://raw.githubusercontent.com/vortaxx2008/VNC-MAC/refs/heads/main/login.sh"

# --- Disable Spotlight indexing ---
sudo mdutil -i off -a

# --- Create new admin account ---
sudo dscl . -create /Users/runneradmin
sudo dscl . -create /Users/runneradmin UserShell /bin/bash
sudo dscl . -create /Users/runneradmin RealName "Runner_Admin"
sudo dscl . -create /Users/runneradmin UniqueID 1001
sudo dscl . -create /Users/runneradmin PrimaryGroupID 80
sudo dscl . -create /Users/runneradmin NFSHomeDirectory /Users/tcv
sudo dscl . -passwd /Users/runneradmin 'P@ssw0rd!'
sudo createhomedir -c -u runneradmin > /dev/null
sudo dscl . -append /Groups/admin GroupMembership runneradmin

# --- Enable VNC ---
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -allowAccessFor -allUsers -privs -all

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes

echo runnerrdp | perl -we '
BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA" };
$_ = <>; chomp;
s/^(.{8}).*/$1/;
@p = unpack "C*", $_;
foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) };
print "\n"
' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# --- Restart ARD/VNC service ---
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

# --- Install & Setup Tailscale (replacing ngrok) ---
curl -fsSL https://tailscale.com/install.sh | sh

# Start tailscaled (userspace networking mode)
sudo tailscaled --tun=userspace-networking & 
sleep 5

# Login to Tailscale using ephemeral auth key from GitHub Secrets
sudo tailscale up --authkey "$1" --hostname github-mac --accept-dns=false

echo "✅ Tailscale connected!"
tailscale ip -4
tailscale ip -6
