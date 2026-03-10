#!/usr/bin/env zsh
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"
if [[ -f "$DOTFILES/zsh/.zshrc" ]]; then
  source "$DOTFILES/zsh/.zshrc"
else
  echo "dotfiles: missing $DOTFILES/zsh/.zshrc" >&2
fi
