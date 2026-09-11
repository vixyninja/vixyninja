# Dotfiles

Personal configuration for a Zsh-first development environment: shell setup, editor/CLI preferences, and service configs.

## Structure

```
vixyninja/
├── zsh/          single-file Zsh configuration
├── home/         files to symlink into $HOME
├── services/     Glance and Nginx service configs
├── scripts/      bootstrap, backup, restore, diff, audit
└── docs/         setup notes
```

AI agent configuration lives in `.claude/`, `.codex/` and `.opencode/` — see
[ai-agents.md](ai-agents.md).

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

## Install

```bash
DOTFILES=$HOME/dotfiles
git clone git@github.com:vixyninja/vixyninja.git "$DOTFILES"
cd "$DOTFILES"
./scripts/bootstrap.sh
```

`bootstrap.sh` links `.profile` and `.zshrc`, then restores the AI configuration. The
remaining `home/` files are opt-in — symlink the ones you want:

```bash
ln -sf "$DOTFILES/home/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/home/.tmux.conf" "$HOME/.tmux.conf"
# ... and so on
```

After a re-login, `.profile` exports `DOTFILES` and `ZDOTDIR`, and zsh reads `zsh/.zshrc` automatically.

## services

See [services.md](services.md) for Glance and Nginx.

## Secrets

Keep credentials, private keys, tokens, and host-specific values outside this repository.
