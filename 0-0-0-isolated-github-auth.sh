#!/bin/sh
# -----------------------------
# Prompt for GitHub username and Personal Access Token (PAT)
# -----------------------------
printf 'Enter GitHub Personal Access Token (PAT): '
read -r GITHUB_TOKEN

# -----------------------------
# apk add dependencies
# -----------------------------
apk add git curl jq openssh

# -----------------------------
# Github authentication
# -----------------------------
mkdir -p /root/.ssh

# # # # # Generate Ed25519 SSH key (Replaces RSA)
ssh-keygen -t ed25519 -a 100 -f /root/.ssh/id_ed25519 -N ""

# Upload public key to github
set +x
curl -H "Authorization: token ${GITHUB_TOKEN}" \
     -H "Content-Type: application/json" \
     -d "$(jq -n --arg title "Alpine $(hostname) Ed25519" --arg key "$(cat /root/.ssh/id_ed25519.pub)" '{title:$title, key:$key}')" \
     https://api.github.com/user/keys
set -x

# # # # # Configure SSH config (Updated for Ed25519)
cat << EOF > /root/.ssh/config
Host github.com
User git
IdentityFile /root/.ssh/id_ed25519
IdentitiesOnly yes
EOF

# # # # # Preseed known_hosts file
ssh-keyscan github.com >> /root/.ssh/known_hosts

# # # # # Configure chmod permissions
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_ed25519
chmod 644 /root/.ssh/id_ed25519.pub
chmod 600 /root/.ssh/config
chmod 600 /root/.ssh/known_hosts

# # # # # Connect to Github
ssh -T git@github.com || true
