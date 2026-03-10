export SHELL="/bin/zsh"
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export MANPATH="/usr/local/man:${MANPATH:-}"
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="$LANG"
export EDITOR="${EDITOR:-nvim}"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="${EDITOR:-vim}"
fi

export GOPATH="${GOPATH:-$HOME/go}"
export GOROOT="${GOROOT:-/usr/local/go}"
export GO111MODULE="on"
export GOPROXY="https://proxy.golang.org,direct"
export GOSUMDB="sum.golang.org"
export GOMODCACHE="$GOPATH/pkg/mod"
export GOLANGCI_LINT_CACHE="$HOME/.cache/golangci-lint"
export GOENV_DISABLE_AUTO_UPDATE=1

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history
setopt share_history
HIST_STAMPS="dd/mm/yyyy"

export ARCHFLAGS="-arch $(uname -m)"
