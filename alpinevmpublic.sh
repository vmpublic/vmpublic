#!/bin/sh
set -eux

# -----------------------------
# Alpine VM Setup Script
# -----------------------------
# Create /home/vmuser0 because of weirdness
mkdir -p /home/vmuser0
# Networking auto-setup
wget -O /home/vmuser0/networking-auto-setup.sh https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/networking-auto-setup.sh
chmod +x /home/vmuser0/networking-auto-setup.sh

# -----------------------------
# Update repositories and system
# -----------------------------
apk update
apk upgrade

# -----------------------------
# Primary packages
# -----------------------------
apk add \
    doas \
    git \
    wget \
    curl \
    jq \
    openssh \
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
    earlyoom \
    libreoffice-calc \
    libreoffice-gtk3
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
  wireplumber
# -----------------------------
# XWayland (specifically for painless webcam functionality in zoom in firefox - as sway-only config seemingly won't behave)
apk add xwayland
# -----------------------------
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
# Configure libreofficecalc
# -----------------------------
mkdir -p /home/vmuser0/.config/libreoffice/4/user
rm -f /home/user0/.config/libreoffice/4/user/registrymodifications.xcu
wget -O /home/vmuser0/.config/libreoffice/4/user/registrymodifications.xcu https://raw.githubusercontent.com/vmpublic/vmpublic/main/libreofficecalc/registrymodifications.xcu
# then in later section I also add a gtk theme entry to the env file to darken the libreofficecalc frame
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
tee /etc/profile.d/vmuser0-env.sh <<'EOF'
# Core Paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Specifics for Wayland / Sway
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=pixman
# Specifics for screensharing via zoom in firefox in sway
export XDG_CURRENT_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1
# Specifics for painless webcam functionality in zoom in firefox in sway - as sway-only config seemingly won't behave
export GDK_BACKEND=x11
# Libreofficecalc appearance
export GTK_THEME="Adwaita:dark"
# Quality of Life Aliases
alias xx='doas -u root'
alias volup='wpctl set-volume @DEFAULT_SINK@ 0.1+'
alias voldown='wpctl set-volume @DEFAULT_SINK@ 0.1-'
EOF
# Ensure it is readable by everyone
chmod 644 /etc/profile.d/vmuser0-env.sh
# -----------------------------
# Set wlr as default xdg portal - important for screensharing via zoom in firefox in sway
# But now using zoom flatpak client so may not need this section - keeping for now anyway
# -----------------------------
mkdir -p /home/vmuser0/.config/xdg-desktop-portal
tee /home/vmuser0/.config/xdg-desktop-portal/portals.conf <<'EOF'
[preferred]
default=wlr
EOF
# -----------------------------
# Configuring zoom flatpak client
# -----------------------------
apk add flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install us.zoom.Zoom
flatpak override  us.zoom.Zoom --talk-name=org.freedesktop.portal.Desktop
# -----------------------------
# Grant vmuser0 full ownership
# -----------------------------
chown -R vmuser0:vmuser0 /home/vmuser0
# -----------------------------
# Reboot and apply changes
# -----------------------------
reboot
