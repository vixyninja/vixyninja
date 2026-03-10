setopt MENU_COMPLETE
setopt AUTO_LIST
COMPLETION_WAITING_DOTS="true"

if [[ -z "$ZSH_COMPDUMP" ]]; then
  export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
fi

autoload -Uz compinit
compdump_dir="${ZSH_COMPDUMP%/*}"
[[ -d "$compdump_dir" ]] || mkdir -p -- "$compdump_dir"
compinit -d "$ZSH_COMPDUMP"
