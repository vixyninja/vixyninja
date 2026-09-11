#!/usr/bin/env bash
# New-machine entrypoint: check dependencies, link the shell configuration, restore
# the portable AI configuration, then print the steps that must be done by hand.
# Installs nothing and authenticates nothing.
#
#   ./scripts/bootstrap.sh [--dry-run] [--yes]

set -euo pipefail
# shellcheck source=scripts/_manifest.sh
source "$(dirname "${BASH_SOURCE[0]}")/_manifest.sh"

for a in "$@"; do
	case "$a" in
	--dry-run | -n) DRY_RUN=1 ;;
	--yes | -y) ASSUME_YES=1 ;;
	-h | --help)
		sed -n '2,6p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) die "unknown argument '$a'" ;;
	esac
done

section "dependencies"
missing=0
for t in git rsync zsh; do
	if command -v "$t" >/dev/null; then
		info "  ok       $t"
	else
		printf '  MISSING  %s (required)\n' "$t"
		missing=$((missing + 1))
	fi
done
for t in jq yq shellcheck gitleaks claude opencode; do
	if command -v "$t" >/dev/null; then info "  ok       $t"; else info "  absent   $t (optional)"; fi
done
[[ $missing -eq 0 ]] || die "$missing required dependency/dependencies missing"

# .profile exports DOTFILES and ZDOTDIR, which is what makes zsh/.zshrc load at login.
section "shell"
link_item "$REPO_ROOT/home/.profile" "$HOME/.profile" ".profile"
link_item "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc" ".zshrc"
info "  note     remaining home/ dotfiles are opt-in, see docs/dotfiles.md"

section "ai configuration"
flags=()
[[ $DRY_RUN -eq 1 ]] && flags+=(--dry-run)
[[ $ASSUME_YES -eq 1 ]] && flags+=(--yes)
"$REPO_ROOT/scripts/restore-ai.sh" ${flags[@]+"${flags[@]}"} all

section "manual steps"
cat <<'EOF'
  1. claude              authenticate, then: claude plugin marketplace add ...
                         (exact commands in docs/ai-agents.md)
  2. codex               sign in through the ChatGPT app, then merge .codex/config.toml
  3. opencode            export the OPENCODE_* variables listed in docs/ai-agents.md
  4. ./scripts/diff-ai.sh    confirm machine and repository agree
EOF
