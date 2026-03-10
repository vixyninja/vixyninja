# ~/.profile sourced for login shells

export DOTFILES="${DOTFILES:-$HOME/dotfiles}"

if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi
export PATH

if [ -f "$DOTFILES/zsh/.zshrc" ]; then
  export ZDOTDIR="$DOTFILES/zsh"
fi
