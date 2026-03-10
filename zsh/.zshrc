#!/usr/bin/env zsh

export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

typeset -a _dotfiles_modules=(
  "exports.zsh"
  "path.zsh"
  "aliases.zsh"
  "functions.zsh"
  "completion.zsh"
  "plugins.zsh"
  "prompt.zsh"
)

for module in "${_dotfiles_modules[@]}"; do
  module_path="$DOTFILES/zsh/$module"
  if [[ -f "$module_path" ]]; then
    source "$module_path"
  else
    printf 'dotfiles: skip missing %s\n' "$module_path" >&2
  fi
done

unset _dotfiles_modules
