# Server Setup Guide

1. Clone the repository to `~/dotfiles`.
2. Review and update `.env` using `.env.example` as the template.
3. Run `./bootstrap.sh` to install packages, developer tools, and baseline security tooling.
4. Execute `./install.sh` to create symlinks into `$HOME`.
5. Enable optional systemd units from `system/systemd` using `sudo systemctl enable --now backup@<user>.timer`.
6. Customize service definitions under `services/` before running `docker compose up`.

All configuration files are modular, making it easy to replace sections without editing monolithic dotfiles.
