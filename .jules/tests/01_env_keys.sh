#!/bin/sh

# Test: Check for required keys in .env.example
echo "### Test: .env.example keys"
KEYS="POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB DATABASE_URL PGSSLMODE"
MISSING_KEYS=0

# This file is not committed, so we create a dummy one for the test
if [ ! -f ".env.example" ]; then
  echo "❌ .env.example not found."
  exit 1
fi

for key in $KEYS; do
  if ! grep -q "^${key}=" .env.example; then
    echo "❌ Missing key: $key"
    MISSING_KEYS=$((MISSING_KEYS + 1))
  else
    echo "✅ Found key: $key"
  fi
done

if [ $MISSING_KEYS -ne 0 ]; then
  exit 1
fi

echo "✅ All required keys are present in .env.example."
exit 0