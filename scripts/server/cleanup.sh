#!/usr/bin/env bash
set -euo pipefail

sudo journalctl --vacuum-time=14d
docker system prune -f
