# Powerlevel10k instant prompt should load before anything that might prompt for input
# Simple prompt configuration without Powerlevel10k
autoload -Uz colors && colors

PROMPT='%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$(git_prompt_info) %# '

ZSH_THEME="" # disable theme to use custom PROMPT
