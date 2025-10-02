#!/bin/sh

# Test: Check for required Makefile targets
echo "### Test: Makefile targets"
TARGETS="up down ps logs restart health verify"
MISSING_TARGETS=0

for target in $TARGETS; do
  if ! grep -q "^${target}:" Makefile; then
    echo "❌ Missing Makefile target: $target"
    MISSING_TARGETS=$((MISSING_TARGETS + 1))
  else
    echo "✅ Found Makefile target: $target"
  fi
done

if [ $MISSING_TARGETS -ne 0 ]; then
  exit 1
fi

echo "✅ All required Makefile targets are present."
exit 0