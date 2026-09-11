#!/usr/bin/env bash
# Compare live machine configuration against the repository copy. Changes nothing.
# Exits non-zero when the two sides differ, so it is usable as a pre-commit check.
#
#   ./scripts/diff-ai.sh [claude|codex|opencode|all]

set -euo pipefail
# shellcheck source=scripts/_manifest.sh
source "$(dirname "${BASH_SOURCE[0]}")/_manifest.sh"

case "${1:-}" in
-h | --help)
	sed -n '2,5p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
	exit 0
	;;
esac

differs=0

report() {
	local label="$1" body="$2"
	if [[ -z $body ]]; then
		info "  same     $label"
		return
	fi
	differs=1
	printf '  differs  %s\n' "$label"
	printf '%s\n' "$body" | sed 's/^/             /'
}

# "live" is the left-hand side: '-' lines are on the machine, '+' lines are in the repo.
diff_item() {
	local live="$1" repo="$2" label="$3"
	# An empty live directory is nothing to sync, which is how backup-ai.sh treats it.
	if [[ -d $live && -z "$(find "$live" -type f -print -quit)" && ! -e $repo ]]; then
		return
	fi
	if [[ ! -e $live && ! -e $repo ]]; then
		return
	fi
	if [[ ! -e $live ]]; then
		report "$label" "only in repository"
		return
	fi
	if [[ ! -e $repo ]]; then
		report "$label" "only on this machine (run backup-ai.sh)"
		return
	fi
	if [[ -d $live ]]; then
		report "$label" "$(diff -ru "$live" "$repo" || true)"
	else
		report "$label" "$(diff -u "$live" "$repo" || true)"
	fi
}

diff_generic() {
	local tool="$1" src dst item
	src="$(tool_src "$tool")"
	dst="$(tool_dst "$tool")"
	section "$(printf '%-8s %s <-> %s' "$tool" "$src" "${dst#"$REPO_ROOT"/}")"
	while read -r item; do
		diff_item "$src/$item" "$dst/$item" "$item"
	done < <(tool_items "$tool")
}

diff_codex() {
	local staged
	diff_generic codex

	if [[ -f $CODEX_SRC/config.toml && -f $CODEX_DST/config.toml ]]; then
		staged="$(mktemp)"
		grep -E "$CODEX_CONFIG_KEYS" "$CODEX_SRC/config.toml" >"$staged" || true
		report "config.toml (whitelisted keys)" \
			"$(diff -u "$staged" <(grep -E "$CODEX_CONFIG_KEYS" "$CODEX_DST/config.toml" || true) || true)"
		rm -f "$staged"
	fi
}

# The live file still holds real credentials, so both sides are sanitized before
# comparison -- otherwise every run would report a spurious difference.
diff_opencode() {
	section "$(printf '%-8s %s <-> %s' opencode "$OPENCODE_SRC" "${OPENCODE_DST#"$REPO_ROOT"/}")"
	local item live staged
	while read -r item; do
		live="$OPENCODE_SRC/$item"
		if [[ ! -f $live ]]; then
			diff_item "$live" "$OPENCODE_DST/$item" "$item"
			continue
		fi
		staged="$(mktemp)"
		sanitize_opencode <"$live" >"$staged"
		if [[ -f $OPENCODE_DST/$item ]]; then
			report "$item (credentials masked on both sides)" \
				"$(diff -u "$staged" "$OPENCODE_DST/$item" || true)"
		else
			report "$item" "only on this machine (run backup-ai.sh)"
		fi
		rm -f "$staged"
	done < <(tool_items opencode)
}

while read -r tool; do
	if declare -f "diff_$tool" >/dev/null; then
		"diff_$tool"
	else
		diff_generic "$tool"
	fi
done < <(resolve_tool_args "$@")

section "result"
if [[ $differs -eq 0 ]]; then
	info "live configuration matches the repository"
else
	info "differences found -- ./scripts/backup-ai.sh to pull, ./scripts/restore-ai.sh to push"
fi
exit "$differs"
