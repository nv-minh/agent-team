#!/bin/bash
#
# EM-Skill Quick Command
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

echo -e "${BLUE}⚡ EM-Skill Quick Task${NC}"
echo "======================"
echo ""

# Check for task description
if [ -z "$1" ]; then
    echo "Usage: em-skill quick <task-description>"
    echo ""
    echo "Examples:"
    echo "  em-skill quick fix typo in README"
    echo "  em-skill quick add error handling to auth"
    echo "  em-skill quick update dependencies"
    echo ""
    echo "This executes the task with:"
    echo "  - No planning overhead"
    echo "  - Atomic commit on completion"
    echo "  - Essential quality gates only"
    echo ""
    echo "For larger tasks, use: em-skill plan"
    exit 1
fi

TASK_DESC="$@"
TASK_ID=$(date +%s)

echo "Task: $TASK_DESC"
echo "ID: $TASK_ID"
echo ""

# Create task file
TASK_FILE=".em-skill/task-$TASK_ID.md"
mkdir -p .em-skill

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
echo "When done, run: em-skill quick-complete $TASK_ID"
