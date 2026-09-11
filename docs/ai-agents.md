# AI agent configuration

Claude Code, Codex, and OpenCode configuration: what is versioned, what is deliberately
not, and how to move it between machines.

## Canonical source

`.claude/` is canonical. `~/.claude/CLAUDE.md` defines the engineering behaviour; the
other two tools get thin adaptations rather than copies:

| Tool      | Role            | Instruction file                        |
| --------- | --------------- | --------------------------------------- |
| Claude    | canonical       | `.claude/CLAUDE.md`                     |
| Codex     | thin adaptation | `.codex/AGENTS.md`                      |
| OpenCode  | thin adaptation | inherits `AGENTS.md` per repository     |

`.agents/` is not a fourth agent — it is the shared skills lock used across tools.

## What is versioned

### Claude — `~/.claude`

| Path                | Why                                           |
| ------------------- | --------------------------------------------- |
| `CLAUDE.md`         | authored global instructions, the canonical file |
| `settings.json`     | permissions, model, effort, plugin declarations |
| `keybindings.json`  | authored key bindings                         |
| `agents/*.md`       | authored subagents: code-reviewer, security-auditor, test-engineer |

`rules/`, `hooks/`, and `commands/` are in the backup whitelist but do not exist on the
current machine. `skills/` exists but is empty — see [Skills](#skills) below. All four
start syncing automatically once they contain files.

Excluded, all of it runtime or machine state: `history.jsonl`, `projects/`, `sessions/`,
`session-env/`, `shell-snapshots/`, `paste-cache/`, `file-history/`, `daemon*`, `jobs/`,
`tasks/`, `plans/`, `backups/`, `cache/`, `ide/`, `stats-cache.json`,
`mcp-needs-auth-cache.json`, and `.claude.json` (contains `machineID` and `userID`).

`settings.local.json` is excluded on purpose: it holds per-machine permission grants
(Homebrew services, Tailscale, local log paths) that should not follow you to a new
machine.

### Codex — `~/.codex`

Only `.codex/AGENTS.md` and a preference fragment travel.

`~/.codex/config.toml` is **not** copied. On this machine it is generated and owned by
the ChatGPT app: absolute app bundle paths, bundled marketplace locations, binary
SHA-256 allowlists, and a `[projects.*]` trust list that leaks private project paths.
`backup-ai.sh` rebuilds `.codex/config.toml` from a three-key whitelist (`model`,
`model_reasoning_effort`, `service_tier`) and labels it a merge fragment.

Excluded: `auth.json`, all `*.sqlite*` (logs, threads, memories, queue, state),
`.codex-global-state.json`, `sessions/`, `dictation-history/`, `transcription-history.jsonl`,
`cache/`, `logs*`, `plugins/`, `skills/.system/` (vendor skills shipped with the app),
and `installation_id`.

### OpenCode — `~/.config/opencode`

`opencode.json` only, with credentials redacted on the way in. `backup-ai.sh` rewrites
every `apiKey` and `Authorization` value to an `{env:...}` placeholder, then refuses to
write the file at all if anything credential-shaped survives.

Excluded: `node_modules/`, `package.json`, `package-lock.json`, `.remember/`,
`.claude/settings.local.json`, and `skills/` — downloaded third-party content, not
authored configuration. See [Skills](#skills).

### Cross-agent skills — `~/.agents`

`.skill-lock.json` only. It records every skill installed from git — source repo, path,
and folder hash — which is all that is needed to reinstall them.

`~/.agents/skills/` itself (5.3 MB) is excluded: downloaded bodies, reproducible from
the lock.

## Skills

Skills come from four places on this machine, and only one of them is authored by you:

| Source                          | Count | Versioned                      |
| ------------------------------- | ----- | ------------------------------ |
| Built into Claude Code          | ~10   | no, ships with the CLI         |
| Claude plugins (`plugins/cache/`) | 6 plugins | no, declared in `settings.json` |
| `~/.agents/skills/` (from git)  | 8     | lock file only                 |
| `~/.config/opencode/skills/`    | 3     | no, see below                  |

There are **no user-authored skills**. `~/.claude/skills/` is empty, so nothing is
backed up from it — the whitelist entry is there and will pick files up the moment you
write one.

The 8 skills under `~/.agents/skills/` all come from one repo, `heygen-com/hyperframes`
(`hyperframes`, `-animation`, `-cli`, `-core`, `-creative`, `-keyframes`, `-registry`,
and `media-use`). Reinstall them with the `hyperframes` CLI, which is what wrote the
lock file:

```bash
npx hyperframes@0.7.70        # check --help for the install subcommand
```

`~/.config/opencode/skills/` holds 3 real directories (`generate2dmap`,
`generate2dsprite`, `video2dsprite` — 336 KB of downloaded game-asset skills, one marked
"Grok Build ONLY"). They are not versioned: downloaded third-party content, not
configuration.

### Broken symlinks, needs a decision

The other 9 entries in `~/.config/opencode/skills/` are **dangling symlinks** pointing at
`~/.claude/skills/<name>`, which is now empty:

```text
hyperframes, hyperframes-{animation,cli,core,creative,keyframes,registry}, media-use
  -> ../../../.claude/skills/<name>   (target missing)
```

They were created on 24 Jul alongside `~/.agents/`; `~/.claude/skills/` was emptied on
11 Sep. The real content still exists at `~/.agents/skills/`. Repointing them fixes it:

```bash
cd ~/.config/opencode/skills
for s in hyperframes hyperframes-animation hyperframes-cli hyperframes-core \
         hyperframes-creative hyperframes-keyframes hyperframes-registry media-use; do
  ln -sfn "$HOME/.agents/skills/$s" "$s"
done
```

Left alone deliberately — it is live machine state, not repository content.

## Secrets

Nothing in this repository should ever hold a credential. OpenCode reads `{env:NAME}`
placeholders at load time, so export the real values from your shell instead:

```bash
export OPENCODE_API_KEY='...'       # provider API key
export OPENCODE_AUTH_HEADER='...'   # only if a provider needs a raw Authorization header
```

Keep these in a file that is not in this repository, and source it from your shell.

MCP servers are versioned only when their definition is a plain command with no
credentials — `codegraph` in `opencode.json` qualifies. A server needing a token must
read it from the environment.

## Plugins

Plugin implementations are downloaded caches and are never versioned. What is versioned
is the declaration: `enabledPlugins` and `extraKnownMarketplaces` in
`.claude/settings.json`. `plugins/installed_plugins.json` and
`plugins/known_marketplaces.json` are excluded — they are install state, full of
absolute paths and timestamps.

Currently declared, and how to reinstall on a new machine:

```bash
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add DietrichGebert/ponytail

claude plugin install gopls-lsp@claude-plugins-official
claude plugin install code-review@claude-plugins-official
claude plugin install commit-commands@claude-plugins-official
claude plugin install context7@claude-plugins-official
claude plugin install remember@claude-plugins-official
claude plugin install redis-development@claude-plugins-official
claude plugin install ponytail@ponytail
```

Restoring `settings.json` alone is usually enough — Claude installs the declared plugins
on next start. The commands above are the fallback.

## Workflows

### Day to day

```bash
./scripts/diff-ai.sh              # what drifted since last time
./scripts/backup-ai.sh --dry-run  # what a sync would change
./scripts/backup-ai.sh            # pull machine -> repository
./scripts/audit.sh                # secret and runtime-state gate
git diff                          # review, then commit yourself
```

Each script also takes a single tool name: `claude`, `codex`, `opencode`, or `agents`.
Scripts never commit and never push.

### New Mac

```bash
git clone https://github.com/vixyninja/vixyninja.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap.sh --dry-run
./scripts/bootstrap.sh
```

`bootstrap.sh` checks dependencies, links `.profile` and `.zshrc`, calls
`restore-ai.sh`, and prints the manual steps. It installs nothing and authenticates
nothing.

Then, by hand:

1. `claude` — sign in; confirm the declared plugins installed.
2. Codex — sign in through the ChatGPT app, then merge `.codex/config.toml` into
   `~/.codex/config.toml`. Do not replace that file.
3. OpenCode — export the `OPENCODE_*` variables above.
4. Skills — reinstall the ones locked in `.agents/.skill-lock.json` (see [Skills](#skills)).
5. `./scripts/diff-ai.sh` — confirm machine and repository agree.

## Restore semantics

`restore-ai.sh` never overwrites silently. For anything already present it prints a
diff, asks, and moves the old file to `<name>.pre-restore.<timestamp>` before replacing.

| Target                          | Method  | Why                                        |
| ------------------------------- | ------- | ------------------------------------------ |
| `~/.claude/CLAUDE.md`           | symlink | authored, edited in the repository         |
| `~/.claude/agents/`             | symlink | authored                                   |
| `~/.claude/rules/` `skills/` `hooks/` `commands/` | symlink | authored, once they exist    |
| `~/.claude/settings.json`       | copy    | Claude rewrites it for UI and plugin state |
| `~/.claude/keybindings.json`    | copy    | same                                       |
| `~/.codex/AGENTS.md`            | symlink | authored                                   |
| `~/.codex/config.toml`          | manual  | interleaved with app-generated state       |
| `~/.config/opencode/opencode.json` | copy | OpenCode rewrites it                       |
| `~/.agents/.skill-lock.json`    | copy    | the skill installer rewrites it            |

Symlinking a file the tool rewrites would leave the working tree permanently dirty,
which is why the mutable ones are copies.
