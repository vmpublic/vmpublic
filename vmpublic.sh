#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------
# Minimal Debian VM Setup Script
# -----------------------------
# Sway + Wayland + Zoom + public dotfiles
# -----------------------------

# # # # # # Disable power state changes
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # Edit /etc/apt/sources.list
tee /etc/apt/sources.list << 'EOF'
deb https://deb.debian.org/debian/ bookworm main contrib
deb-src https://deb.debian.org/debian/ bookworm main contrib
deb https://security.debian.org/ bookworm-security main contrib
deb-src https://security.debian.org/ bookworm-security main contrib
deb https://deb.debian.org/debian/ bookworm-backports main contrib
deb-src https://deb.debian.org/debian/ bookworm-backports main contrib
EOF

# Update system
apt-get update
apt-get upgrade -y

# -----------------------------
# Set debconf to stop tshark from interrupting with prompt
# -----------------------------
echo wireshark-common wireshark-common/install-setuid boolean false | debconf-set-selections

# -----------------------------
# Primary packages
# -----------------------------
apt-get install -y \
    sudo \
    git \
    vim \
    tmux \
    wget \
    curl \
    zip \
    unzip \
    gzip \
    fzf \
    ffmpeg \
    mpv \
    neofetch \
    firefox-esr \
    fonts-unifont \
    dnsutils \
    net-tools \
    tshark \
    ncat \
    nmap \
    build-essential \
    jq \
    earlyoom

# -----------------------------
# Wayland / Sway / screen sharing
# -----------------------------
apt-get install -y \
    sway \
    foot \
    grim \
    slurp \
    libwayland-dev \
    libxkbcommon-dev \
    wl-clipboard \
    pipewire \
    pipewire-pulse \
    wireplumber \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr

# -----------------------------
# Configure earlyoom
# -----------------------------
systemctl enable earlyoom.service
systemctl start earlyoom.service

# -----------------------------
# Set PATH for root and user0
# -----------------------------
echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"' >> /root/.bashrc
echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"' >> /home/user0/.bashrc

# -----------------------------
# Set groups for user0
# -----------------------------
usermod -aG sudo,tty,adm,video user0

# -----------------------------
# Install yt-dlp
#  -----------------------------
wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp

# -----------------------------
# Pull and configure public dotfiles for user0
# -----------------------------

# -----------------------------
# Pull public dotfiles
# -----------------------------

# Sway config
mkdir -p /etc/sway
wget -O /etc/sway/config https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/config

# Foot config
mkdir -p /etc/xdg
wget -O /etc/xdg/foot.ini https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/foot.ini

# Vim .vimrc for user0
wget -O /home/user0/.vimrc https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/.vimrc

# -----------------------------
# Grant user0 full ownership of their home directory
# -----------------------------
chown -R user0:user0 /home/user0

# -----------------------------
# Install Zoom (latest .deb)
# -----------------------------
ZOOM_DEB="/tmp/zoom_latest_amd64.deb"
wget -O "$ZOOM_DEB" https://zoom.us/client/latest/zoom_amd64.deb
apt-get install -y "$ZOOM_DEB"
rm -f "$ZOOM_DEB"

# -----------------------------
# Cleanup
# -----------------------------
apt-get autoremove -y
apt-get clean
