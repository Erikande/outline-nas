#!/bin/sh
# POSIX-safe rclone runner (no bash, no eval, no subshell exec)
set -eu

: "${BACKUP_SRC:?BACKUP_SRC env required}"             # e.g. /work/storage
: "${BACKUP_REMOTE:?BACKUP_REMOTE env required}"       # e.g. local
: "${BACKUP_DEST:?BACKUP_DEST env required}"           # e.g. /work/backups/_local_dest
: "${RCLONE_CONFIG_FILE:?RCLONE_CONFIG_FILE required}" # e.g. /work/backups/rclone/rclone.conf
: "${RCLONE_FLAGS:=}"                                   # e.g. "--fast-list --stats=15s"

MODE="${1:---dry-run}"  # default dry-run; pass --once for real run

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p backups/artifacts
LOG="backups/artifacts/backup_${STAMP}.log"

# Build argument vector for rclone
# Avoid globbing when expanding flags
set -f
# Base args
set -- rclone --config="$RCLONE_CONFIG_FILE" sync "$BACKUP_SRC" "${BACKUP_REMOTE}:${BACKUP_DEST}"
# Append flags if provided (split on spaces)
if [ -n "$RCLONE_FLAGS" ]; then
  # shellcheck disable=SC2086 # intentional: split flags on spaces
  set -- "$@" $RCLONE_FLAGS
fi
# Append dry-run unless explicitly --once
[ "$MODE" = "--dry-run" ] && set -- "$@" --dry-run

# Pretty print the command to the log
{
  echo ">>> MODE: $MODE"
  printf '>>> CMD :'
  for a in "$@"; do printf ' %s' "$a"; done
  printf '\n'
} | tee "$LOG"

# Execute and tee output to the same log
"$@" 2>&1 | tee -a "$LOG"

echo "wrote: $LOG"
