#!/bin/sh

# Test Runner Script
# Executes all .jules/tests/*.sh scripts in sorted order,
# captures their output, and generates a Markdown report.

TEST_DIR=".jules/tests"
REPORT_FILE="jules_report.md"
OVERALL_STATUS=0

# Initialize report file
echo "# Jules Test Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Find and run test scripts
for test_script in $(find "$TEST_DIR" -name '*.sh' | sort); do
  TEST_NAME=$(basename "$test_script")
  echo "## Test: $TEST_NAME" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo '```' >> "$REPORT_FILE"

  # Execute the test script and capture output
  if sh "$test_script" >> "$REPORT_FILE" 2>&1; then
    echo "✅ $TEST_NAME passed."
  else
    echo "❌ $TEST_NAME failed."
    OVERALL_STATUS=1
  fi

  echo '```' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
done

if [ $OVERALL_STATUS -ne 0 ]; then
  echo "🔥 One or more tests failed. See $REPORT_FILE for details."
  exit 1
fi

echo "✅ All tests passed successfully. See $REPORT_FILE for details."
exit 0