# Dotfiles

Personal configuration for a Zsh-first development environment: shell setup, editor/CLI preferences, and service configs.

## Structure

```
vixyninja/
├── zsh/          single-file Zsh configuration
├── home/         files to symlink into $HOME
├── services/     Nginx server & snippet configs
└── docs/         setup notes
```

## zsh

`zsh/.zshrc` is one self-contained file organized the standard zsh way:

1. **Environment** — `LANG`, `EDITOR`, Go toolchain (`GOPATH`, `GOROOT`, `GOPROXY`, ...)
2. **Shell options** — history appending/sharing, completion, correction off
3. **Path** — `~/bin`, `~/.local/bin`, `~/.cargo/bin`, Go bins
4. **History** — file, size, timestamps
5. **Completion** — `compinit` with a cached dump
6. **Plugins** — oh-my-zsh (git, golang, docker, syntax highlighting, autosuggestions)
7. **Prompt** — minimal user@host + git branch
8. **Aliases & functions** — `mkcd`, `tre`, git/docker shortcuts

## home

Symlink what you want into `$HOME`:

- `.gitconfig`, `.gitignore_global`
- `.profile` — exports `DOTFILES` and sets `ZDOTDIR` so login shells load the managed config
- `.tmux.conf`, `.vimrc`
- `.editorconfig`, `.prettierrc`, `.prettierignore`
- `.config/` — nvim, zed, VS Code, golangci-lint, dart
- `glance.yml` — Glance dashboard config (`~/.config/glance/glance.yml`)

## Install

```bash
DOTFILES=$HOME/dotfiles
git clone git@github.com:vixyninja/vixyninja.git "$DOTFILES"

ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/home/.profile" "$HOME/.profile"
# ... symlink any other home/ files you use
```

After a re-login, `.profile` exports `DOTFILES` and `ZDOTDIR`, and zsh reads `zsh/.zshrc` automatically.

## services

`services/nginx` holds server and snippet configs. Copy them into `/etc/nginx` on the host as needed, adapting server names and upstream ports.

## Secrets

Keep credentials, private keys, tokens, and host-specific values outside this repository.
