#!/usr/bin/env bash
# Single source of truth for what counts as portable AI configuration.
# Sourced by backup-ai.sh, restore-ai.sh and diff-ai.sh so the three can never disagree.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CLAUDE_SRC="$HOME/.claude"
CLAUDE_DST="$REPO_ROOT/.claude"
CLAUDE_ITEMS=(CLAUDE.md settings.json keybindings.json agents rules skills hooks commands)

# ~/.codex on this machine is ChatGPT.app-managed state: absolute app paths, bundled
# marketplace locations, binary checksum allowlists and a per-project trust list.
# Only hand-set preferences travel; config.toml is rebuilt from CODEX_CONFIG_KEYS.
CODEX_SRC="$HOME/.codex"
CODEX_DST="$REPO_ROOT/.codex"
CODEX_ITEMS=(AGENTS.md)
# shellcheck disable=SC2034  # consumed by backup-ai.sh / diff-ai.sh
CODEX_CONFIG_KEYS='^(model|model_reasoning_effort|service_tier) *='

OPENCODE_SRC="$HOME/.config/opencode"
OPENCODE_DST="$REPO_ROOT/.opencode"
OPENCODE_ITEMS=(opencode.json)

# Cross-agent skills installed from git. Only the lock file travels; the skill bodies
# under ~/.agents/skills are downloaded content and are reinstalled from it.
AGENTS_SRC="$HOME/.agents"
AGENTS_DST="$REPO_ROOT/.agents"
AGENTS_ITEMS=(.skill-lock.json)

TOOLS=(claude codex opencode agents)

DRY_RUN=0
ASSUME_YES=0
STAMP="$(date +%Y%m%d-%H%M%S)"

die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

info() { printf '%s\n' "$*"; }

tilde() { printf '~%s' "${1#"$HOME"}"; }

section() { printf '\n== %s ==\n' "$*"; }

resolve_tool_args() {
	local args=("$@")
	if [[ ${#args[@]} -eq 0 || ${args[0]} == all ]]; then
		printf '%s\n' "${TOOLS[@]}"
		return
	fi
	local t
	for t in "${args[@]}"; do
		case "$t" in
		claude | codex | opencode | agents) printf '%s\n' "$t" ;;
		*) die "unknown tool '$t' (expected: claude, codex, opencode, agents, all)" ;;
		esac
	done
}

tool_src() {
	case "$1" in
	claude) printf '%s' "$CLAUDE_SRC" ;;
	codex) printf '%s' "$CODEX_SRC" ;;
	opencode) printf '%s' "$OPENCODE_SRC" ;;
	agents) printf '%s' "$AGENTS_SRC" ;;
	esac
}

tool_dst() {
	case "$1" in
	claude) printf '%s' "$CLAUDE_DST" ;;
	codex) printf '%s' "$CODEX_DST" ;;
	opencode) printf '%s' "$OPENCODE_DST" ;;
	agents) printf '%s' "$AGENTS_DST" ;;
	esac
}

tool_items() {
	case "$1" in
	claude) printf '%s\n' "${CLAUDE_ITEMS[@]}" ;;
	codex) printf '%s\n' "${CODEX_ITEMS[@]}" ;;
	opencode) printf '%s\n' "${OPENCODE_ITEMS[@]}" ;;
	agents) printf '%s\n' "${AGENTS_ITEMS[@]}" ;;
	esac
}

# Redact provider credentials on the way into the repository. OpenCode expands
# {env:NAME} at load time, so the sanitized file stays functional after restore.
sanitize_opencode() {
	sed -E \
		-e 's/("apiKey"[[:space:]]*:[[:space:]]*")[^"]*(")/\1{env:OPENCODE_API_KEY}\2/' \
		-e 's/("Authorization"[[:space:]]*:[[:space:]]*")[^"]*(")/\1{env:OPENCODE_AUTH_HEADER}\2/'
}

# A long unbroken token, or one sitting next to a credential keyword, is treated as live.
SECRET_VALUE_RE='(sk|pk|ghp|gho|xox[baprs])-[A-Za-z0-9_-]{16,}|(apikey|api_key|secret|password|bearer|basic|token|credential)["'"'"':= ]+[A-Za-z0-9+/_-]{24,}'

contains_secret() {
	grep -Eiq "$SECRET_VALUE_RE" -- "$1" 2>/dev/null
}

confirm() {
	if [[ $ASSUME_YES -eq 1 ]]; then
		return 0
	fi
	if [[ ! -t 0 ]]; then
		info "             skipped: not a terminal, re-run with --yes to replace"
		return 1
	fi
	local reply
	read -r -p "             replace it? [y/N] " reply
	[[ $reply == [yY] ]]
}

preserve() {
	local target="$1" backup="$1.pre-restore.$STAMP"
	mv "$target" "$backup"
	info "             backed up to $(tilde "$backup")"
}

# Authored, human-edited content: a symlink keeps the machine and the repo in step.
link_item() {
	local src="$1" target="$2" label="$3"
	[[ -e $src ]] || return 0
	if [[ -L $target && "$(readlink "$target")" == "$src" ]]; then
		info "  ok       $label (already linked)"
		return 0
	fi
	printf '  link     %s -> %s\n' "$(tilde "$target")" "${src#"$REPO_ROOT"/}"
	if [[ -e $target || -L $target ]]; then
		if [[ -f $target && -f $src && ! -L $target ]]; then
			diff -u "$target" "$src" | sed 's/^/             /' || true
		else
			info "             existing entry will be replaced"
		fi
		[[ $DRY_RUN -eq 1 ]] && return 0
		confirm || return 0
		preserve "$target"
	fi
	[[ $DRY_RUN -eq 1 ]] && return 0
	mkdir -p "$(dirname "$target")"
	ln -s "$src" "$target"
}

# Files the tool rewrites at runtime: copy, so the working tree does not go dirty.
copy_out() {
	local src="$1" target="$2" label="$3"
	[[ -f $src ]] || return 0
	if [[ -f $target && ! -L $target ]] && cmp -s "$src" "$target"; then
		info "  ok       $label (identical)"
		return 0
	fi
	printf '  copy     %s\n' "$(tilde "$target")"
	if [[ -e $target || -L $target ]]; then
		if [[ -f $target && ! -L $target ]]; then
			diff -u "$target" "$src" | sed 's/^/             /' || true
		else
			info "             existing entry will be replaced"
		fi
		[[ $DRY_RUN -eq 1 ]] && return 0
		confirm || return 0
		preserve "$target"
	fi
	[[ $DRY_RUN -eq 1 ]] && return 0
	mkdir -p "$(dirname "$target")"
	cp "$src" "$target"
}
