#!/usr/bin/env bash
# Scan the working tree for credentials and for runtime state that should never be
# versioned. Exits non-zero on any finding, so it is usable as a pre-commit gate.
#
#   ./scripts/audit.sh

set -euo pipefail
# shellcheck source=scripts/_manifest.sh
source "$(dirname "${BASH_SOURCE[0]}")/_manifest.sh"

cd "$REPO_ROOT"

findings=0

fail() {
	findings=$((findings + 1))
	printf '  FINDING  %s\n' "$*"
}

# Everything git would ship: tracked files plus untracked ones that are not ignored.
tracked_files() {
	git ls-files -z --cached --others --exclude-standard
}

section "external scanners"
if command -v gitleaks >/dev/null; then
	gitleaks detect --no-banner --redact --source . || fail "gitleaks reported secrets"
elif command -v trufflehog >/dev/null; then
	trufflehog filesystem --no-update --fail . || fail "trufflehog reported secrets"
else
	info "  none installed (gitleaks, trufflehog) -- pattern scan only"
	info "  brew install gitleaks"
fi

section "credential values"
while IFS= read -r -d '' f; do
	[[ -f $f ]] || continue
	if contains_secret "$f"; then
		fail "credential-shaped value in $f"
		grep -Ein "$SECRET_VALUE_RE" -- "$f" | head -3 | cut -c1-120 | sed 's/^/             /'
	fi
done < <(tracked_files)

# Keyword hits are not findings by themselves; they are printed for human review.
section "credential keywords (review, not findings)"
KEYWORD_RE='api[_-]?key|client_secret|private[_-]?key|passwd|password|authorization|bearer|credential|cookie'
hits="$(git grep -Ein "$KEYWORD_RE" -- . ':!scripts/audit.sh' ':!scripts/_manifest.sh' ':!docs' 2>/dev/null | head -20 || true)"
if [[ -n $hits ]]; then
	printf '%s\n' "$hits" | cut -c1-120 | sed 's/^/  /'
else
	info "  none"
fi

section "runtime state"
RUNTIME_RE='(^|/)(history\.jsonl|session_index\.jsonl|sessions?|projects|shell-snapshots|shell_snapshots|paste-cache|session-env|file-history|daemon|jobs|tasks|stats-cache\.json|installed_plugins\.json|known_marketplaces\.json|auth\.json|\.credentials\.json)(/|$)|\.(sqlite|sqlite3|sqlite-wal|sqlite-shm|log|pem|key)$'
while IFS= read -r -d '' f; do
	if printf '%s' "$f" | grep -Eq "$RUNTIME_RE"; then
		fail "runtime or generated state: $f"
	fi
done < <(tracked_files)

section "node_modules and caches"
while IFS= read -r -d '' f; do
	case "$f" in
	*/node_modules/* | */.DS_Store | */cache/* | */.env | */.env.*) fail "should not be versioned: $f" ;;
	esac
done < <(tracked_files)

section "result"
if [[ $findings -eq 0 ]]; then
	info "clean: no credentials or runtime state in the working tree"
else
	info "$findings finding(s) -- resolve before committing"
fi
exit $((findings > 0))
