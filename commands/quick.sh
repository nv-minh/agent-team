#!/bin/bash
#
# EM-Team Quick Command
# Source: GSD quick task execution
#
# Execute quick tasks with minimal overhead
# Use for small, self-contained tasks
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}⚡ EM-Team Quick Task${NC}"
echo "======================"
echo ""

# Check for task description
if [ -z "$1" ]; then
    echo "Usage: em-team quick <task-description>"
    echo ""
    echo "Examples:"
    echo "  em-team quick fix typo in README"
    echo "  em-team quick add error handling to auth"
    echo "  em-team quick update dependencies"
    echo ""
    echo "This executes the task with:"
    echo "  - No planning overhead"
    echo "  - Atomic commit on completion"
    echo "  - Essential quality gates only"
    echo ""
    echo "For larger tasks, use: em-team plan"
    exit 1
fi

TASK_DESC="$@"
TASK_ID=$(date +%s)

echo "Task: $TASK_DESC"
echo "ID: $TASK_ID"
echo ""

# Create task file
TASK_FILE=".em-team/task-$TASK_ID.md"
mkdir -p .em-team

cat > "$TASK_FILE" << EOF
# Quick Task: $TASK_DESC

**ID:** $TASK_ID
**Started:** $(date)

## Task Description
$TASK_DESC

## Execution Checklist
- [ ] Understand the task
- [ ] Make necessary changes
- [ ] Run tests
- [ ] Run linter
- [ ] Create atomic commit
- [ ] Verify changes

## Notes
Add any notes during execution here.

EOF

echo "✓ Task file created: $TASK_FILE"
echo ""
echo "Next steps:"
echo "  1. Implement the changes"
echo "  2. Run tests: npm test"
echo "  3. Run linter: npm run lint"
echo "  4. Commit changes"
echo ""
echo "When done, run: em-team quick-complete $TASK_ID"
