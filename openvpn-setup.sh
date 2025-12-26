# -----------------------------
# OPENVPN (Alpine POSIX)
# -----------------------------
# 1. Install dependencies
apk add git openvpn openresolv
modprobe tun && echo "tun" >> /etc/modules

# 2. Setup Resources
rm -rf /tmp/protonvpn-openvpn-resources
git clone --depth 1 git@github.com:s1z1g1/protonvpn-openvpn-resources.git /tmp/protonvpn-openvpn-resources
mkdir -p /etc/openvpn
mv /tmp/protonvpn-openvpn-resources/jp-free-120024.protonvpn.tcp.ovpn /etc/openvpn/config.ovpn

# 3. Credentials
printf 'INSERTLONGSECRETKEYHERE\n' > /etc/openvpn/auth.txt
chmod 600 /etc/openvpn/auth.txt

# 4. Configure .ovpn (Inline DNS logic)
tmp=$(mktemp) || exit 1

# Clean out old up/down lines and update auth-user-pass
sed -e '/^up /d' \
    -e '/^down /d' \
    -e 's|^auth-user-pass.*|auth-user-pass /etc/openvpn/auth.txt|' \
    /etc/openvpn/config.ovpn > "$tmp"

# Append the Alpine-compatible DNS one-liners
cat << 'EOF' >> "$tmp"
script-security 2
up "/bin/sh -c 'env | grep foreign_option_ | grep DNS | cut -d= -f2 | cut -d \" \" -f3 | sed \"s/^/nameserver /\" | resolvconf -a $dev.inet'"
down "/bin/sh -c 'resolvconf -d $dev.inet'"
EOF

mv -f "$tmp" /etc/openvpn/config.ovpn
rm -rf /tmp/protonvpn-openvpn-resources
