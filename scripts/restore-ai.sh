#!/usr/bin/env bash
# Install the repository's portable AI configuration onto this machine.
# Authored content is symlinked; files the tools rewrite themselves are copied.
# Existing files are shown as a diff and backed up before anything is replaced.
#
#   ./scripts/restore-ai.sh [--dry-run] [--yes] [claude|codex|opencode|all]

set -euo pipefail
# shellcheck source=scripts/_manifest.sh
source "$(dirname "${BASH_SOURCE[0]}")/_manifest.sh"

args=()
for a in "$@"; do
	case "$a" in
	--dry-run | -n) DRY_RUN=1 ;;
	--yes | -y) ASSUME_YES=1 ;;
	-h | --help)
		sed -n '2,6p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) args+=("$a") ;;
	esac
done

# Claude rewrites these itself (UI state, plugin toggles); symlinking them would keep
# the working tree permanently dirty.
CLAUDE_COPY_ITEMS=" settings.json keybindings.json "

restore_claude() {
	section "claude   ${CLAUDE_DST#"$REPO_ROOT"/} -> $CLAUDE_SRC"
	local item
	while read -r item; do
		if [[ $CLAUDE_COPY_ITEMS == *" $item "* ]]; then
			copy_out "$CLAUDE_DST/$item" "$CLAUDE_SRC/$item" "$item"
		else
			link_item "$CLAUDE_DST/$item" "$CLAUDE_SRC/$item" "$item"
		fi
	done < <(tool_items claude)
	info "  note     plugins are not restored -- see docs/ai-agents.md"
}

restore_codex() {
	section "codex    ${CODEX_DST#"$REPO_ROOT"/} -> $CODEX_SRC"
	local item
	while read -r item; do
		link_item "$CODEX_DST/$item" "$CODEX_SRC/$item" "$item"
	done < <(tool_items codex)

	# Never written automatically: the live file interleaves these preferences with
	# app-generated plugin, marketplace and project-trust state.
	if [[ -f $CODEX_DST/config.toml ]]; then
		info "  manual   merge these keys into ~/.codex/config.toml:"
		grep -v '^#' "$CODEX_DST/config.toml" | grep -v '^$' | sed 's/^/             /'
	fi
}

restore_opencode() {
	section "opencode ${OPENCODE_DST#"$REPO_ROOT"/} -> $OPENCODE_SRC"
	# The repository copy carries {env:...} placeholders where the live file has real
	# keys, so restoring over a working machine trades them for the environment.
	info "  warning  this replaces live API keys with {env:...} placeholders;"
	info "           export the OPENCODE_* variables from docs/ai-agents.md first"
	local item
	while read -r item; do
		copy_out "$OPENCODE_DST/$item" "$OPENCODE_SRC/$item" "$item"
	done < <(tool_items opencode)
}

# The lock file is the record of which skills to reinstall; the installer rewrites it,
# and the skill bodies under ~/.agents/skills are downloaded, never restored from here.
restore_agents() {
	section "agents   ${AGENTS_DST#"$REPO_ROOT"/} -> $AGENTS_SRC"
	local item
	while read -r item; do
		copy_out "$AGENTS_DST/$item" "$AGENTS_SRC/$item" "$item"
	done < <(tool_items agents)
	info "  manual   reinstall the locked skills, see docs/ai-agents.md"
}

[[ $DRY_RUN -eq 1 ]] && info "dry-run: nothing will be written"

while read -r tool; do
	"restore_$tool"
done < <(resolve_tool_args ${args[@]+"${args[@]}"})

section "result"
info "credentials and runtime state are never restored -- authenticate each tool manually"
