#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Unmount NAS Outline
# @raycast.mode silent
# @raycast.icon ⏏️
# @raycast.packageName NAS
# @raycast.description Unmount NAS Outline share

set -euo pipefail
LOCAL_DIR="$HOME/nas-outline"

if mount | grep -q "on $LOCAL_DIR "; then
  sudo umount "$LOCAL_DIR"
  echo "✅ Unmounted $LOCAL_DIR"
else
  echo "Not mounted: $LOCAL_DIR"
fi
