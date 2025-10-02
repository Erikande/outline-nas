#!/bin/sh

# Test: Check for repository policy files
echo "### Test: Repository policy"
CHECKS_FAILED=0

# 1. Check for commitlint.config.cjs
if [ -f "commitlint.config.cjs" ]; then
  echo "✅ commitlint.config.cjs exists."
else
  echo "❌ commitlint.config.cjs is missing."
  CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

# 2. Check for lint-staged in package.json
if command -v jq >/dev/null && jq -e '.["lint-staged"]' package.json > /dev/null; then
  echo "✅ package.json contains a 'lint-staged' section."
elif grep -q '"lint-staged":' package.json; then
  echo "✅ package.json contains a 'lint-staged' section (checked with grep)."
else
  echo "❌ package.json is missing the 'lint-staged' section."
  CHECKS_FAILED=$((CHECKS_FAILED + 1))
fi

if [ $CHECKS_FAILED -ne 0 ]; then
  exit 1
fi

echo "✅ All repository policy checks passed."
exit 0