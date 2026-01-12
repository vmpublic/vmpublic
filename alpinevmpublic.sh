#!/bin/sh
set -eux

# -----------------------------
# Alpine VM Setup Script
# -----------------------------
# Create /home/vmuser0 because of weirdness
mkdir -p /home/vmuser0
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
    wget \
    curl \
    git \
    vim \
    tmux \
    zip \
    unzip \
    gzip \
    fzf \
    ffmpeg \
    mpv \
    fastfetch \
    firefox \
    bind-tools \
    net-tools \
    tshark \
    nmap \
    nmap-ncat \
    font-terminus \
    build-base \
    jq \
    earlyoom

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
    swaylock \
    mesa-dri-gallium \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    seatd \
    pam-rundir \
    util-linux-login \
    dbus

# -----------------------------
# Pipewire
# -----------------------------
apk add \
  pipewire \
  pipewire-pulse \
  wireplumber \
# -----------------------------
# Configure earlyoom (OpenRC)
# -----------------------------
rc-update add earlyoom default
rc-service earlyoom start
# -----------------------------
# -----------------------------
# Configure eudev
# -----------------------------
setup-devd udev
# -----------------------------
# Configure seatd (OpenRC)
# -----------------------------
rc-update add seatd default
rc-service seatd start
# -----------------------------
# Configure dbus (OpenRC)
# -----------------------------
rc-update add dbus default
rc-service dbus start
# -----------------------------
# Set groups for vmuser0
# -----------------------------
# Alpine uses addgroup instead of usermod
for grp in wheel tty adm input audio video seat; do
    addgroup vmuser0 $grp
done
# -----------------------------
# Set doas config to allow wheel group
# -----------------------------
mkdir -p /etc/doas.d
printf "%s\n" "permit persist :wheel" > /etc/doas.d/doas.conf
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
wget -O /etc/xdg/foot/foot.ini https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/foot.ini
wget -O /home/vmuser0/.vimrc https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/.vimrc

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
# Global Environment Variables
# -----------------------------
tee /etc/profile.d/user0-env.sh <<'EOF'
# Core Paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Wayland / Sway Specifics
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=pixman
# Quality of Life Aliases
alias xx='doas -u root'
EOF
# Ensure it is readable by everyone
chmod 644 /etc/profile.d/user0-env.sh
# -----------------------------
# Grant vmuser0 full ownership
# -----------------------------
chown -R vmuser0:vmuser0 /home/vmuser0

# -----------------------------
# Cleanup
# -----------------------------
reboot
