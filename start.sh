#!/bin/bash

echo ">>> Starting Mac VNC setup..."

# ------------------------------
# 1) Disable Spotlight indexing
# ------------------------------
sudo mdutil -i off -a

# ------------------------------
# 2) Create new admin account
# ------------------------------
sudo dscl . -create /Users/runneradmin
sudo dscl . -create /Users/runneradmin UserShell /bin/bash
sudo dscl . -create /Users/runneradmin RealName "Runner_Admin"
sudo dscl . -create /Users/runneradmin UniqueID 1001
sudo dscl . -create /Users/runneradmin PrimaryGroupID 80
sudo dscl . -create /Users/runneradmin NFSHomeDirectory /Users/tcv
sudo dscl . -passwd /Users/runneradmin P@ssw0rd!
sudo createhomedir -c -u runneradmin > /dev/null
sudo dscl . -append /Groups/admin GroupMembership runneradmin

# ------------------------------
# 3) Enable VNC
# ------------------------------
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -allowAccessFor -allUsers -privs -all

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes 

echo runnerrdp | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' \
  | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

# ------------------------------
# 4) Install Tailscale via pkg (CLI support)
# ------------------------------
echo ">>> Installing Tailscale CLI..."
TS_VERSION=$(curl -s https://api.github.com/repos/tailscale/tailscale/releases/latest \
  | grep "tag_name" | cut -d '"' -f 4)

curl -L -o tailscale.pkg "https://pkgs.tailscale.com/stable/tailscale-${TS_VERSION}.pkg"
sudo installer -pkg tailscale.pkg -target /

# ------------------------------
# 5) Start Tailscale
# ------------------------------
echo ">>> Starting Tailscale..."
sudo tailscaled --tun=userspace-networking &
sleep 5

sudo tailscale up --authkey "$1" --hostname github-mac --accept-dns=false

echo "✅ Tailscale connected!"
echo "IPv4: $(tailscale ip -4)"
echo "IPv6: $(tailscale ip -6)"
