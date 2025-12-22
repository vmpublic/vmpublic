#!/bin/sh
set -eux

# -----------------------------
# Minimal Debian VM Setup Script
# -----------------------------

# # # # # # Networking auto-setup for future runs
wget -O /home/vmuser0/networking-auto-setup.sh https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/networking-auto-setup.sh
chmod +x /home/vmuser0/networking-auto-setup.sh

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
printf 'wireshark-common wireshark-common/install-setuid boolean false\n' | debconf-set-selections

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
    earlyoom \
    pipewire \
    pipewire-pulse \
    wireplumber

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
# Set PATH for root and vmuser0
# -----------------------------
printf 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"\n' >> /etc/profile

# -----------------------------
# Set wayland variables for enabling cursor in sway
# -----------------------------
printf 'export WLR_NO_HARDWARE_CURSORS=1\n' >> /etc/profile
printf 'export WLR_RENDERER=pixman\n' >> /etc/profile
# -----------------------------
# Set groups for vmuser0
# -----------------------------
usermod -aG sudo,tty,adm,video vmuser0

# -----------------------------
# Install yt-dlp
#  -----------------------------
wget -O /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp

# -----------------------------
# Pull public dotfiles
# -----------------------------

# Sway config
mkdir -p /etc/sway
wget -O /etc/sway/config https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/config

# Foot config
mkdir -p /etc/xdg
wget -O /etc/xdg/foot.ini https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/foot.ini

# Vim .vimrc for vmuser0
wget -O /home/vmuser0/.vimrc https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/.vimrc

# -----------------------------
# Configure busybox ash as default shell
# -----------------------------
# First create script to call busybox ash
tee /usr/bin/busybox-ash.sh << 'EOF'
#!/bin/sh
. /etc/profile
exec /usr/bin/busybox ash "$@"
EOF
chmod +x /usr/bin/busybox-ash.sh
# Set busybox ash script as shell for login
usermod -s /usr/bin/busybox-ash.sh root
usermod -s /usr/bin/busybox-ash.sh vmuser0
# Set busybox ash script as shell for tmux
tee /etc/tmux.conf << 'EOF'
set-option -g default-shell /usr/bin/busybox-ash.sh
EOF
# -----------------------------
# Configure tmux
# -----------------------------
tee /etc/tmux.conf << 'EOF'
set-option -g status-style bg=black,fg=white
set-option -g status-position top
set-option -g pane-border-style fg=white
set-option -g pane-active-border-style fg=white
EOF

# -----------------------------
# Grant vmuser0 full ownership of their home directory
# -----------------------------
chown -R vmuser0:vmuser0 /home/vmuser0

# -----------------------------
# Cleanup
# -----------------------------
apt-get autoremove -y
apt-get clean
