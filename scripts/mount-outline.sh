#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Mount NAS Outline
# @raycast.mode silent
# @raycast.icon 💽
# @raycast.packageName NAS
# @raycast.description Mount NAS Outline share over Tailscale NFS

set -euo pipefail

LOCAL_DIR="$HOME/nas-outline"
NAS_HOST="100.xx.xx.xx"                 # Tailscale IP or MagicDNS hostname
NAS_PATH="/volume1/Docker/outline"      # NAS path for Outline data

mkdir -p "$LOCAL_DIR"

if mount | grep -q "on $LOCAL_DIR "; then
  echo "Already mounted: $LOCAL_DIR"
  exit 0
fi

sudo mount -t nfs -o resvport "$NAS_HOST:$NAS_PATH" "$LOCAL_DIR"
echo "✅ Mounted $NAS_HOST:$NAS_PATH -> $LOCAL_DIR"
