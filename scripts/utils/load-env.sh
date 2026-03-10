#!/usr/bin/env bash
set -euo pipefail

load_env() {
  local env_file="${1:-.env}"
  if [[ ! -f "$env_file" ]]; then
    return 0
  fi
  set -o allexport
  # shellcheck disable=SC1090
  source "$env_file"
  set +o allexport
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  load_env "${1:-.env}"
fi
