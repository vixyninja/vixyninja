export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

ENABLE_CORRECTION="false"
unsetopt correct_all
unsetopt correct

plugins=(
  git
  git-prompt
  golang
  docker
  docker-compose
  zsh-syntax-highlighting
  zsh-autosuggestions
)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  printf 'dotfiles: unable to find oh-my-zsh at %s\n' "$ZSH" >&2
fi
