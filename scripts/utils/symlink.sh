#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_ROOT/ensure-dir.sh"

symlink_file() {
  local source_path="$1"
  local target_path="$2"

  if [[ ! -e "$source_path" ]]; then
    echo "symlink: missing source $source_path" >&2
    return 1
  fi

  ensure_dir "$(dirname "$target_path")"

  if [[ -L "$target_path" ]]; then
    local current
    current="$(readlink "$target_path")"
    if [[ "$current" == "$source_path" ]]; then
      return 0
    fi
    rm "$target_path"
  elif [[ -e "$target_path" ]]; then
    local backup="$target_path.$(date +%Y%m%d%H%M%S).bak"
    mv "$target_path" "$backup"
    echo "symlink: moved existing $target_path to $backup"
  fi

  ln -s "$source_path" "$target_path"
  echo "symlink: $target_path -> $source_path"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  symlink_file "${1:-}" "${2:-}"
fi
