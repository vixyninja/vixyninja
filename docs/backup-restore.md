# Backup & Restore

## Backup

Run `scripts/server/backup.sh` to create timestamped archives under `$HOME/backups`. Use `system/systemd/backup.*` to automate via `systemctl enable --now backup@<user>.timer`.

## Restore

Invoke `scripts/server/restore.sh <backup-path>` to sync files back into place. Always verify permissions and sensitive files after the restore.

## Recommendations

- Replicate the `backups/` directory to off-site storage.
- Keep encryption keys outside the repository (password manager, vault, etc.) and fetch them during provisioning.
