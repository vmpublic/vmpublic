#!/bin/sh
set -eux
# -----------------------------
# Prompt for GitHub Personal Access Token (PAT) and export it
# -----------------------------
printf 'Enter GitHub Personal Access Token (PAT): '
read -r GITHUB_TOKEN
export GITHUB_TOKEN
# -----------------------------
# Disable IPv6 (GRUB)
# -----------------------------
tmp=$(mktemp) || exit 1
sed '/^GRUB_CMDLINE_LINUX="/s/"$/ ipv6.disable=1"/' /etc/default/grub >"$tmp"
mv -f "$tmp" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
# -----------------------------
# Update repositories and upgrade system
# -----------------------------
tee /etc/apk/repositories << 'EOF'
https://dl-cdn.alpinelinux.org/alpine/v3.23/main
https://dl-cdn.alpinelinux.org/alpine/v3.23/community
EOF
apk update
apk upgrade
# -----------------------------
# apk primary section
# -----------------------------
apk add \
    doas \
    wget \
    curl \
    git \
    man-pages \
    mandoc \
    docs \
    vim \
    tmux \
    python3 \
    zip \
    unzip \
    gzip \
    fzf \
    ffmpeg \
    mpv \
    fastfetch \
    bind-tools \
    net-tools \
    tshark \
    nmap \
    nmap-ncat \
    font-terminus \
    build-base \
    jq \
    earlyoom \
    shellcheck \
    connman \
    taskwarrior \
    libreoffice-calc \
    libreoffice-gtk3 \
    openvpn \
    openvpnresolv \
    gnupg \
    pass \
    ca-certificates \
    megacmd \
    ffmpeg \
    ldmtool \
    mpv \
    rtorrent \
    inkscape \
    gimp
 # -----------------------------
 # apk secondary section for Wayland / Sway / screen sharing
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
     util-linux-login
 # -----------------------------
 # apk tertiary section for Pipewire
 # -----------------------------
 apk add \
     pipewire \
     pipewire-pulse \
     wireplumber \
     dbus
 # -----------------------------
 # Github authentication
 # -----------------------------
mkdir -p /root/.ssh
# # # # # Generate SSH key
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
# Upload public key to github
set +x
curl -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type: application/json" -d "$(jq -n --arg title "Alpine Linux $(hostname)" --arg key "$(cat /root/.ssh/id_rsa.pub)" '{title:$title, key:$key}')" https://api.github.com/user/keys
set -x
# # # # # Configure SSH config
tee /root/.ssh/config <<'EOC'
Host github.com
User git
IdentityFile /root/.ssh/id_rsa
IdentitiesOnly yes
EOC
# # # # # Preseed known_hosts file
ssh-keyscan github.com >> /root/.ssh/known_hosts
# # # # # Configure chmod permissions
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/config
chmod 600 /root/.ssh/known_hosts
# # # # # Connect to Github (including || true otherwise exits even on success)
ssh -T git@github.com || true
unset GITHUB_TOKEN
# -----------------------------
# SC-IM Build (Hardened POSIX Style)
# -----------------------------
# Alpine-specific build deps
apk add --no-cache libzip-dev libxml2-dev ncurses-dev build-base git
rm -rf /tmp/sc-im
git clone --depth 1 https://github.com/andmarti1424/sc-im.git /tmp/sc-im
# 1. Prepare transformation
tmp=$(mktemp) || exit 1
# 2. POSIX sed: Match line starting with LDLIBS, replace everything after =
# We use -r only if we need extended regex, but for this, standard is fine.
sed '/^LDLIBS/s|=.*|= -lm -lncursesw -lzip -lxml2|' \
    /tmp/sc-im/src/Makefile > "$tmp"
# 3. Atomic replacement
if [ $? -eq 0 ]; then
    mv -f "$tmp" /tmp/sc-im/src/Makefile
else
    echo "Error: sed failed to modify Makefile" >&2
    rm -f "$tmp"
    exit 1
fi
# 4. Compile and Install
# -j$(nproc) uses all CPU cores for significantly faster Alpine builds
make -C "/tmp/sc-im/src" -j$(nproc)
make -C "/tmp/sc-im/src" install
rm -rf /tmp/sc-im
