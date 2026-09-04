#!/usr/bin/env zsh
export SHELL="/bin/zsh"
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="$LANG"
export MANPATH="/usr/local/man:${MANPATH:-}"
export ARCHFLAGS="-arch $(uname -m)"

export EDITOR="${EDITOR:-nvim}"
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="vim"
fi

export GOPATH="${GOPATH:-$HOME/go}"
export GOROOT="${GOROOT:-/usr/local/go}"
export GO111MODULE="on"
export GOPROXY="https://proxy.golang.org,direct"
export GOSUMDB="sum.golang.org"
export GOMODCACHE="$GOPATH/pkg/mod"
export GOLANGCI_LINT_CACHE="$HOME/.cache/golangci-lint"
export GOENV_DISABLE_AUTO_UPDATE=1

setopt inc_append_history
setopt share_history
setopt MENU_COMPLETE
setopt AUTO_LIST
unsetopt correct_all
unsetopt correct

ENABLE_CORRECTION="false"

typeset -U path PATH

path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$GOROOT/bin"
  $path
)

export PATH

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="dd/mm/yyyy"

COMPLETION_WAITING_DOTS="true"

if [[ -z "$ZSH_COMPDUMP" ]]; then
  export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
fi

autoload -Uz compinit
compdump_dir="${ZSH_COMPDUMP%/*}"
[[ -d "$compdump_dir" ]] || mkdir -p -- "$compdump_dir"
compinit -d "$ZSH_COMPDUMP"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

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

autoload -Uz colors && colors
ZSH_THEME=""

PROMPT='%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$(git_prompt_info) %# '

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull --rebase'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias kc='kubectl'
alias editrc='$EDITOR $DOTFILES/zsh/.zshrc'
