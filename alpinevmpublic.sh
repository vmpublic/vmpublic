#!/bin/sh
set -eux

# -----------------------------
# Alpine VM Setup Script
# -----------------------------

# Networking auto-setup (Ensure script uses 'ip' from busybox or iproute2)
wget -O /home/vmuser0/networking-auto-setup.sh https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/networking-auto-setup.sh
chmod +x /home/vmuser0/networking-auto-setup.sh

# -----------------------------
# Update repositories and system
# -----------------------------
# Manual config of repositories shouldn't be needed as Alpine seemingly includes main and community repo by default
apk update
apk upgrade

# -----------------------------
# Primary packages
# -----------------------------
apk add \
    doas \
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
    firefox \
    bind-tools \
    net-tools \
    tshark \
    ncat \
    nmap \
    font-terminus-otb \
    build-base \
    jq \
    earlyoom \
    # possibly also may need to install mesa-dri-gallium but we'll see - apparently essential for Wayland on many VMs

# -----------------------------
# Wayland / Sway / screen sharing
# -----------------------------
apk add \
    sway \
    foot \
    grim \
    slurp \
    wayland-dev \
    libxkbcommon-dev \
    wl-clipboard \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr


# -----------------------------
# Audio
# -----------------------------
apk add \
  pipewire \
  pipewire-pulse \
  wireplumber

# -----------------------------
# Configure earlyoom (OpenRC style)
# -----------------------------
rc-update add earlyoom default
rc-service earlyoom start

# -----------------------------
# Set PATH for root and vmuser0
# -----------------------------
printf 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"\n' >> /etc/profile

# -----------------------------
# Set Wayland variables for enabling cursr in sway
# -----------------------------
printf 'export WLR_NO_HARDWARE_CURSORS=1\n' >> /etc/profile
printf 'export WLR_RENDERER=pixman\n' >> /etc/profile

# -----------------------------
# Set groups for vmuser0
# -----------------------------
# Alpine uses addgroup instead of usermod
for grp in wheel tty adm video; do
    addgroup vmuser0 $grp
done

# -----------------------------
# Install yt-dlp
# -----------------------------
wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp

# -----------------------------
# Pull public dotfiles
# -----------------------------
mkdir -p /etc/sway /etc/xdg
wget -O /etc/sway/config https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/config
wget -O /etc/xdg/foot.ini https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/foot.ini
wget -O /home/vmuser0/.vimrc https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/.vimrc

# -----------------------------
# Default Shell
# -----------------------------
# Alpine's default shell IS busybox ash. No wrapper needed.
# Just keeping this here as comparison for prior vm scripts

# -----------------------------
# Configure tmux
# -----------------------------
# No need to set default shell for tmux since busybox already default
tee /etc/tmux.conf << 'EOF'
set-option -g status-style bg=black,fg=white
set-option -g status-position top
set-option -g pane-border-style fg=white
set-option -g pane-active-border-style fg=white
EOF

# -----------------------------
# Grant vmuser0 full ownership
# -----------------------------
chown -R vmuser0:vmuser0 /home/vmuser0

# -----------------------------
# Cleanup
# -----------------------------
# apk doesn't use 'autoremove' like in Debian, but can clean the cache for good measure
rm -rf /var/cache/apk/*
