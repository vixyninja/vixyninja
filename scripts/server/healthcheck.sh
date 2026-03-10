#!/usr/bin/env bash
set -euo pipefail

echo "[healthcheck] $(date)"
uptime
df -h /
sudo systemctl is-active docker >/dev/null 2>&1 && docker info --format '{{json .ServerVersion}}'
docker ps --format 'table {{.Names}}\t{{.Status}}'
