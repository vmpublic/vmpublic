#!/bin/sh
set -eux

- stripped down version of usual guest setup for use in wsl on work laptop

# -----------------------------
# Alpine VM Setup Script
# -----------------------------
# Create /home/vmuser0 because of weirdness
mkdir -p /home/vmuser0
# Networking auto-setup
wget -O /home/vmuser0/networking-auto-setup.sh https://raw.githubusercontent.com/vmpublic/vmpublic/refs/heads/main/networking-auto-setup.sh
chmod +x /home/vmuser0/networking-auto-setup.sh

# -----------------------------
# Prompt for variables if not already supplied
# (Github authentication assumed already completed from prior script)
# -----------------------------
if [ -z "${GITHUB_USER:-}" ]; then
    printf 'Enter username for Github account: '
    read -r GITHUB_USER
    export GITHUB_USER

# -----------------------------
# Update repositories and system
# -----------------------------
apk update
apk upgrade

# -----------------------------
# Clone vmpublic
# -----------------------------
# git clone --depth 1 https://github.com/vmpublic/vmpublic
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
# Symlink .files for tmux
# -----------------------------
rm -f /etc/tmux.conf
ln -sf /home/vmuser0/.vmdotfiles/tmux/tmux.conf /etc/tmux.conf
# -----------------------------
# Symlink .files for vim
# -----------------------------
rm -f /home/vmuser0/.vimrc
ln -sf /home/vmuser0/.vmdotfiles/vim/vimrc /home/vmuser0/.vimrc
# -----------------------------
# Symlink .files for wayland
# -----------------------------
rm -f /etc/sway/config
ln -sf /home/vmuser0/.vmdotfiles/sway/config /etc/sway/config
rm -f /etc/xdg/foot/foot.ini
ln -sf /home/vmuser0/.vmdotfiles/foot/foot.ini /etc/xdg/foot/foot.ini
# -----------------------------
# Symlink .files for env
# -----------------------------
rm -rf /etc/profile.d/vmuser0-env.sh
mkdir -p /etc/profile.d/
ln -sf /home/vmuser0/.vmdotfiles/vmuser0-env.sh /etc/profile.d/vmuser0-env.sh
# Ensure it is readable by everyone
chmod 644 /etc/profile.d/vmuser0-env.sh
# -----------------------------
# SC-IM Build
# -----------------------------
# Alpine-specific build deps
apk add --no-cache libzip-dev libxml2-dev ncurses-dev build-base bison
rm -rf /tmp/sc-im
git clone --depth 1 https://github.com/andmarti1424/sc-im.git /tmp/sc-im
# 1. Prepare transformation
tmp=$(mktemp) || exit 1
# 2. POSIX sed: Match line starting with LDLIBS, replace everything after =
# Use -r only if extended regex needed
sed '/^LDLIBS/s|=.*|= -lm -lncursesw -lzip -lxml2|' \
    /tmp/sc-im/src/Makefile > "$tmp"
# 3. Atomic replacement
if [ $? -eq 0 ]; then
    mv -f "$tmp" /tmp/sc-im/src/Makefile
else
    printf "%s\n"  "Error: sed failed to modify Makefile" >&2
    rm -f "$tmp"
    exit 1
fi
# 4. Compile and Install
make -C "/tmp/sc-im/src" -j$(nproc)
make -C "/tmp/sc-im/src" install
rm -rf /tmp/sc-im
# -----------------------------
# Termination
# -----------------------------
printf "%s\n" "Setup complete. Now rebooting to ensure all changes applied..."
printf "%s\n" "."
printf "%s\n" "."
printf "%s\n" "."
reboot
