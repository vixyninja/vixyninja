# Security Notes

- Keep secrets (env files, SSH keys, tokens) outside the repository; copy them in manually during provisioning.
- Apply UFW rules via `system/ufw/rules.sh` and keep the default deny policy.
- Fail2ban overrides live in `system/fail2ban/jail.local`; copy them into `/etc/fail2ban/` during provisioning.
- Rotate SSH keys regularly and update `ssh/config.example` for reference only.
- Harden services by enabling TLS termination through Nginx or Caddy snippets.
