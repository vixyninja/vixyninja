#!/usr/bin/env bash
set -euo pipefail

ensure_dir() {
  local dir="$1"
  if [[ -z "$dir" ]]; then
    echo "ensure_dir: missing directory argument" >&2
    return 1
  fi
  if [[ -d "$dir" ]]; then
    return 0
  fi
  mkdir -p -- "$dir"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ensure_dir "${1:-}"
fi
