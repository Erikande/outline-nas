#!/usr/bin/env bash
set -euo pipefail

: "${BACKUP_REMOTE:?BACKUP_REMOTE env required}"
: "${BACKUP_DEST:?BACKUP_DEST env required}"
: "${RCLONE_FLAGS:=}"

MODE="${1:---dry-run}"   # --dry-run  (default)  or  --once

# Build the rclone copy command (source: /data, dest: remote:/path)
RCLONE_CMD=( rclone sync /data "${BACKUP_REMOTE}:${BACKUP_DEST}" ${RCLONE_FLAGS} --progress )

# For local smoke tests (BACKUP_REMOTE=local) the dest becomes a folder.
# rclone understands "local:./backups/_local_dest" as a real path.

# When running in compose, we write a log artifact inside /artifacts
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
LOG=/artifacts/backup_${STAMP}.log

echo ">>> MODE: ${MODE}"
echo ">>> CMD : ${RCLONE_CMD[*]}"
if [[ "${MODE}" == "--dry-run" ]]; then
  RCLONE_CMD+=( --dry-run )
fi

# Execute with a tee'd summary
{ "${RCLONE_CMD[@]}"; } 2>&1 | tee "${LOG}"
echo "Wrote: ${LOG}"
