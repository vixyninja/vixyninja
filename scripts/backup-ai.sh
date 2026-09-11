#!/usr/bin/env bash
# Sync whitelisted portable AI configuration from this machine into the repository.
# Never commits, never pushes, never modifies the live configuration.
#
#   ./scripts/backup-ai.sh [--dry-run] [claude|codex|opencode|all]

set -euo pipefail
# shellcheck source=scripts/_manifest.sh
source "$(dirname "${BASH_SOURCE[0]}")/_manifest.sh"

DRY_RUN=0
args=()
for a in "$@"; do
	case "$a" in
	--dry-run | -n) DRY_RUN=1 ;;
	-h | --help)
		sed -n '2,5p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) args+=("$a") ;;
	esac
done

changed=0

indent() { sed 's/^/             /'; }

run_rsync() {
	if [[ $DRY_RUN -eq 1 ]]; then
		rsync -a --itemize-changes --dry-run "$@"
	else
		rsync -a --itemize-changes "$@"
	fi
}

copy_item() {
	local src="$1" dst="$2" label="$3" out
	if [[ ! -e $src ]]; then
		info "  skip     $label (absent on this machine)"
		return
	fi
	if [[ -d $src && -z "$(find "$src" -type f -print -quit)" ]]; then
		info "  skip     $label (empty)"
		return
	fi

	# Single files are compared directly: macOS ships openrsync, whose --dry-run
	# itemizes every file whether or not it differs, which makes dry-run useless.
	if [[ ! -d $src ]]; then
		install_staged "$src" "$dst" "$label"
		return
	fi

	[[ $DRY_RUN -eq 1 ]] || mkdir -p "$dst"
	out="$(run_rsync --delete "$src/" "$dst/")"

	if [[ -n $out ]]; then
		changed=1
		printf '  update   %s\n' "$label"
		printf '%s\n' "$out" | indent
	else
		info "  ok       $label"
	fi
}

install_staged() {
	local staged="$1" dst="$2" label="$3"
	if [[ -f $dst ]] && cmp -s "$staged" "$dst"; then
		info "  ok       $label"
		return
	fi
	changed=1
	printf '  update   %s\n' "$label"
	if [[ $DRY_RUN -eq 1 ]]; then
		diff -u "$([[ -f $dst ]] && printf '%s' "$dst" || printf '/dev/null')" "$staged" | indent || true
		return
	fi
	mkdir -p "$(dirname "$dst")"
	cp "$staged" "$dst"
}

backup_generic() {
	local tool="$1" src dst item
	src="$(tool_src "$tool")"
	dst="$(tool_dst "$tool")"
	section "$(printf '%-8s %s -> %s' "$tool" "$src" "${dst#"$REPO_ROOT"/}")"
	if [[ ! -d $src ]]; then
		info "  skip     source directory absent"
		return 1
	fi
	while read -r item; do
		copy_item "$src/$item" "$dst/$item" "$item"
	done < <(tool_items "$tool")
}

# config.toml is rebuilt from a key whitelist rather than copied: the live file is
# app-generated and carries absolute paths, binary checksums and a project-trust list.
backup_codex() {
	backup_generic codex || return 0

	if [[ ! -f $CODEX_SRC/config.toml ]]; then
		info "  skip     config.toml (absent on this machine)"
		return
	fi
	local staged
	staged="$(mktemp)"
	{
		printf '# Portable Codex preferences only.\n'
		printf '# Merge these keys into ~/.codex/config.toml -- do not replace that file, it also\n'
		printf '# holds machine-generated plugin, marketplace and project-trust state.\n\n'
		grep -E "$CODEX_CONFIG_KEYS" "$CODEX_SRC/config.toml" || true
	} >"$staged"
	if contains_secret "$staged"; then
		rm -f "$staged"
		die "refusing to stage Codex config.toml: credential-shaped value in whitelisted keys"
	fi
	install_staged "$staged" "$CODEX_DST/config.toml" "config.toml (preferences only)"
	rm -f "$staged"
}

# opencode.json is sanitized on the way in rather than copied: it holds live provider keys.
backup_opencode() {
	section "$(printf '%-8s %s -> %s' opencode "$OPENCODE_SRC" "${OPENCODE_DST#"$REPO_ROOT"/}")"
	if [[ ! -d $OPENCODE_SRC ]]; then
		info "  skip     source directory absent"
		return
	fi
	local item live staged
	while read -r item; do
		live="$OPENCODE_SRC/$item"
		if [[ ! -f $live ]]; then
			info "  skip     $item (absent on this machine)"
			continue
		fi
		staged="$(mktemp)"
		sanitize_opencode <"$live" >"$staged"
		if contains_secret "$staged"; then
			rm -f "$staged"
			die "refusing to stage $item: a credential survived sanitization, redact it by hand"
		fi
		install_staged "$staged" "$OPENCODE_DST/$item" "$item (credentials redacted)"
		rm -f "$staged"
	done < <(tool_items opencode)
}

[[ $DRY_RUN -eq 1 ]] && info "dry-run: nothing will be written"

while read -r tool; do
	if declare -f "backup_$tool" >/dev/null; then
		"backup_$tool"
	else
		backup_generic "$tool" || true
	fi
done < <(resolve_tool_args ${args[@]+"${args[@]}"})

section "result"
if [[ $changed -eq 0 ]]; then
	info "repository already matches the live configuration"
else
	info "repository updated -- review with 'git diff', then run ./scripts/audit.sh"
fi
