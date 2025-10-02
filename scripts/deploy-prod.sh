#!/usr/bin/env bash
set -euo pipefail
echo "Pulling latest..."
git pull --rebase --autostash origin main
echo "Restarting stack..."
docker compose --env-file .env.prod down
docker compose --env-file .env.prod up -d
echo "✅ Deployment complete"
