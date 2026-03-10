#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/backups}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
TARGET="$BACKUP_ROOT/$TIMESTAMP"

mkdir -p "$TARGET"
rsync -a --delete "$HOME/dotfiles/" "$TARGET/dotfiles/"
rsync -a --delete "$HOME/.ssh/" "$TARGET/ssh/"

echo "Backup stored in $TARGET"
