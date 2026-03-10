#!/usr/bin/env bash
set -euo pipefail

ARCHITECTURE="$(dpkg --print-architecture)"
DISTRO_CODENAME="$(lsb_release -cs)"
KEYRING="/usr/share/keyrings/docker-archive-keyring.gpg"

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

if [[ ! -f "$KEYRING" ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "$KEYRING"
fi

echo "deb [arch=${ARCHITECTURE} signed-by=${KEYRING}] https://download.docker.com/linux/ubuntu ${DISTRO_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker "${SUDO_USER:-$USER}"

sudo systemctl enable --now docker
