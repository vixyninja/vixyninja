#!/usr/bin/env bash
set -euo pipefail

BACKUP_PATH="${1:-}"
if [[ -z "$BACKUP_PATH" || ! -d "$BACKUP_PATH" ]]; then
  echo "Usage: restore.sh <backup-directory>" >&2
  exit 1
fi

rsync -a "$BACKUP_PATH/dotfiles/" "$HOME/dotfiles/"
rsync -a "$BACKUP_PATH/ssh/" "$HOME/.ssh/"
