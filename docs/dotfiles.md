## Dotfiles for Ubuntu Home Server

This repository manages every piece of configuration for an Ubuntu-based home server running Zsh. It keeps shell settings, editor preferences, automation scripts, system-level policies, and service manifests organized so a server can be cloned and rebuilt quickly.

### Structure

```
dotfiles/
├── zsh/            # Modular Zsh configuration
├── home/           # Files to symlink into $HOME
├── scripts/        # Setup + server maintenance scripts
├── system/         # Systemd, UFW, Fail2ban, cron, sysctl
├── services/       # Reverse proxy config & service manifests
├── docs/           # Operational documentation
├── install.sh      # Symlink + provisioning helper
└── bootstrap.sh    # Full machine bootstrap
```

### Installation

1. Clone the repository into `~/dotfiles`.
2. Copy `.env.example` to `.env` and adjust ports/paths if needed.
3. Run `./install.sh` to symlink files into your `$HOME` directory and seed `~/.ssh` with the example configs.
4. Restart your shell to load the modular Zsh setup.

### Bootstrap a Fresh Server

Execute `./bootstrap.sh` on a new Ubuntu host. It installs baseline packages, configures Zsh, Docker, Go, Node via nvm, applies security hardening, and finally calls `install.sh`.

### Adding Services

- Track service-specific configs under `services/` (e.g., `services/nginx`).
- Store Docker Compose stacks in their own directories alongside supporting scripts when needed.
- Keep environment-specific secrets out of the repo and load them via `.env` before running `docker compose`.

### Documentation

See the `docs/` directory for detailed server setup, backup/restore, security hardening, and troubleshooting notes.
