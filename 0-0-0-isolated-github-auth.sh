#!/bin/sh
# -----------------------------
# Prompt for GitHub username and Personal Access Token (PAT)
# -----------------------------
printf 'Enter GitHub Personal Access Token (PAT): '
read -r GITHUB_TOKEN
export GITHUB_TOKEN
# -----------------------------
# apk add dependencies
# -----------------------------
apk add git curl jq openssh
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
