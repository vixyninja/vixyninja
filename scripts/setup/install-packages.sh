#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
  build-essential
  curl
  git
  zsh
  tmux
  neovim
  unzip
  htop
  python3-pip
  software-properties-common
)

sudo apt update
sudo apt install -y "${PACKAGES[@]}"
