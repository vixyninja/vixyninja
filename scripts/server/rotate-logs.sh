#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${LOG_DIR:-/var/log/custom}"
mkdir -p "$LOG_DIR"
find "$LOG_DIR" -type f -mtime +14 -print -delete
