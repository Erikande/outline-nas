#!/usr/bin/env bash
set -euo pipefail
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose-outline.yml}"
ENV_FILE="${ENV_FILE:-.env}"
APP_URL="${APP_URL:-http://localhost:3000}"

command -v docker >/dev/null || { echo "❌ docker not found"; exit 1; }
docker compose version >/dev/null || { echo "❌ docker compose v2 not found"; exit 1; }
[[ -f "${ENV_FILE}" ]] || { echo "❌ ${ENV_FILE} missing (cp .env.example .env)"; exit 1; }

missing=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  key="${line%%=*}"
  grep -qE "^${key}=" "${ENV_FILE}" || missing+=("$key")
done < .env.example
((${#missing[@]})) && { echo "❌ Missing keys in ${ENV_FILE}: ${missing[*]}"; exit 1; }

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" config >/dev/null
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d

for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "${APP_URL}" || true)
  [[ "$code" =~ ^2|3 ]] && { echo "✅ ${APP_URL} HTTP ${code}"; exit 0; }
  sleep 2
done
echo "❌ Timeout reaching ${APP_URL}"; exit 1
