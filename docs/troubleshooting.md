# Troubleshooting

- `zsh` fails to start: confirm `DOTFILES` points to `~/dotfiles` and run `./install.sh` again.
- Services do not start: validate `.env` entries inside each compose folder and run `docker compose config` before `up`.
- Systemd timers missing: run `systemctl --user daemon-reload` and re-enable the timer units.
- Secrets leaking: ensure `.gitignore` is intact and keep credentials in an external vault rather than the repo.
