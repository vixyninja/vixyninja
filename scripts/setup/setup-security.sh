#!/usr/bin/env bash
set -euo pipefail

sudo apt install -y ufw fail2ban unattended-upgrades

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw --force enable

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
