#!/bin/sh

# Test: Validate Docker Compose configuration
echo "### Test: Docker Compose configuration"

if ! docker compose -f docker-compose-outline.yml --env-file .env.example config > /dev/null 2>&1; then
  echo "❌ Docker Compose config is invalid."
  exit 1
fi

echo "✅ Docker Compose config is valid."
exit 0