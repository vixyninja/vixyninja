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
