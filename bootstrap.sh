#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$REPO_ROOT/scripts/utils"

# shellcheck disable=SC1090
source "$UTILS_DIR/load-env.sh"
load_env "$REPO_ROOT/.env"

log() {
  echo "[bootstrap] $*"
}

run_step() {
  local script="$1"
  log "Running ${script#$REPO_ROOT/}"
  bash "$script"
}

run_step "$REPO_ROOT/scripts/setup/install-packages.sh"
run_step "$REPO_ROOT/scripts/setup/setup-zsh.sh"
run_step "$REPO_ROOT/scripts/setup/setup-docker.sh"
run_step "$REPO_ROOT/scripts/setup/setup-go.sh"
run_step "$REPO_ROOT/scripts/setup/setup-node.sh"
run_step "$REPO_ROOT/scripts/setup/setup-security.sh"
run_step "$REPO_ROOT/install.sh"

log "Bootstrap complete"
