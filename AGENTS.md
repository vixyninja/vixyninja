# Working in this repository

This repository holds a personal development environment: AI coding-agent
configuration, shell dotfiles, and self-hosted service configuration. It is
configuration, not an application — there is nothing to build or deploy from here.

## Canonical source

`.claude/` is the canonical AI-agent configuration. `.codex/` and `.opencode/` are thin
adaptations of it. When behaviour must be defined once, define it in `.claude/` and
adapt outward — never fan the same content into three places.

## Treat this repository as public

Assume everything committed here is world-readable.

Never commit API keys, tokens, passwords, cookies, provider credentials, SSH private
keys, database credentials, `.env` files, or MCP secrets. Never commit session history,
conversation logs, telemetry, SQLite databases, caches, or downloaded plugin
implementations — only the declarations needed to reinstall them.

If you are unsure whether something is sensitive, leave it out.

`scripts/audit.sh` is the gate. Run it before proposing a commit.

## Changing configuration

Inspect before changing. The files here mirror a live machine, so a change that looks
like a cleanup may be a behaviour change on that machine.

Do not restyle, reorganize, or "improve" rules, agents, skills, permissions, or plugin
declarations because another arrangement seems better. Report what looks questionable
and leave the decision to the owner.

Do not write into `~/.claude`, `~/.codex`, or `~/.config/opencode` directly. The sync
direction is `scripts/backup-ai.sh` (machine to repository) and
`scripts/restore-ai.sh` (repository to machine).

## Code

Shell only, targeting the macOS default `bash` 3.2 — no associative arrays, no `${x,,}`,
guard empty-array expansion under `set -u`. Use `set -euo pipefail`. Keep scripts
idempotent and quoted. Comments explain why, not what.

Prefer the smallest diff that solves the actual problem. Avoid new dependencies,
frameworks, and abstractions with a single caller.

## Before you finish

Run `shellcheck -x scripts/*.sh` and `shfmt -d scripts/*.sh`, run the relevant script in
`--dry-run` first, then review `git diff` in full. Do not commit or push unless asked.
