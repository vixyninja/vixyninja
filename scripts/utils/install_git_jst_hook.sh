#!/usr/bin/env bash

# Git hook installer to amend commit dates to a specific timezone (default: JST)

# ------------- CONFIG -------------
TIMEZONE="Asia/Tokyo"
DATE_FORMAT="%Y-%m-%d %H:%M:%S %z"
PENDING_DATE_FILE=".git/.pending_commit_date"
PRE_HOOK=".git/hooks/pre-commit"
POST_HOOK=".git/hooks/post-commit"

# ------------- CHECKS -------------
if [ ! -d ".git" ]; then
  echo "Error: Current directory is not a Git repository."
  exit 1
fi

if ! command -v date >/dev/null 2>&1; then
  echo "Error: 'date' command is required but not found."
  exit 1
fi

# ------------- PRE-COMMIT HOOK -------------
cat > "$PRE_HOOK" <<EOL
#!/bin/sh
# Save timezone-specific commit date before commit
TZ="$TIMEZONE" date +"$DATE_FORMAT" > "$PENDING_DATE_FILE"
EOL

# ------------- POST-COMMIT HOOK -------------
cat > "$POST_HOOK" <<'EOL'
#!/bin/sh
PENDING_DATE_FILE=".git/.pending_commit_date"

if [ -f "$PENDING_DATE_FILE" ] && [ -z "$GIT_HOOK_AMEND_IN_PROGRESS" ]; then
  JST_DATE=$(cat "$PENDING_DATE_FILE")
  rm -f "$PENDING_DATE_FILE"

  export GIT_HOOK_AMEND_IN_PROGRESS=1

  GIT_COMMITTER_DATE="$JST_DATE" git commit --amend --no-edit --date="$JST_DATE"

  unset GIT_HOOK_AMEND_IN_PROGRESS

  echo "Commit date updated to: $JST_DATE"
fi
EOL

# ------------- PERMISSIONS -------------
chmod +x "$PRE_HOOK" "$POST_HOOK"

# ------------- RESULT -------------
echo "Git hooks installed successfully!"
echo "Timezone: $TIMEZONE"
echo "Date format: $DATE_FORMAT"
echo "All new commits will use the specified timezone."
