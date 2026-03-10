#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$REPO_ROOT/scripts/utils"

# shellcheck disable=SC1090
source "$UTILS_DIR/ensure-dir.sh"
# shellcheck disable=SC1090
source "$UTILS_DIR/symlink.sh"
# shellcheck disable=SC1090
source "$UTILS_DIR/load-env.sh"

load_env "$REPO_ROOT/.env"

log() {
  echo "[install] $*"
}

log "Creating base directories"
ensure_dir "$HOME/.config"
ensure_dir "$HOME/.ssh"
ensure_dir "$HOME/backups"

log "Symlinking dotfiles"
declare -a HOME_LINKS=(
  ".gitconfig"
  ".gitignore_global"
  ".tmux.conf"
  ".vimrc"
  ".profile"
  ".editorconfig"
  ".prettierrc"
  ".prettierignore"
  ".angular"
)

for file in "${HOME_LINKS[@]}"; do
  symlink_file "$REPO_ROOT/home/$file" "$HOME/$file"
done

declare -a CONFIG_DIRS=(
  "nvim"
  "btop"
  "fastfetch"
  "starship.toml"
  "Code"
  "zed"
  "golangci-lint"
  "dart"
)

for entry in "${CONFIG_DIRS[@]}"; do
  symlink_file "$REPO_ROOT/home/.config/$entry" "$HOME/.config/$entry"
done

log "Symlinking Zsh entry point"
symlink_file "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc"

if [[ ! -f "$REPO_ROOT/.env" && -f "$REPO_ROOT/.env.example" ]]; then
  cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
  log "Created .env from template"
fi

for ssh_file in config known_hosts; do
  target="$HOME/.ssh/$ssh_file"
  if [[ ! -f "$target" ]]; then
    cp "$REPO_ROOT/ssh/${ssh_file}.example" "$target"
    chmod 600 "$target"
    log "Seeded $target from example"
  fi
done

log "Install complete"
