#!/bin/bash
#
# EM-Skill Debug Command
# Source: GSD + superpowers systematic debugging
#
# Systematic debugging with root cause investigation
# Iron Law: NO FIXES WITHOUT ROOT CAUSE
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐛 EM-Skill Debug Session${NC}"
echo "========================="
echo ""

# Check for bug description
if [ -z "$1" ]; then
    echo "Usage: em-skill debug <bug-description>"
    echo ""
    echo "Examples:"
    echo "  em-skill debug \"User cannot login after password reset\""
    echo "  em-skill debug \"API returns 500 when creating order\""
    echo "  em-skill debug \"Memory leak in WebSocket handler\""
    echo ""
    echo "This starts a systematic debugging session:"
    echo "  1. INVESTIGATE - Reproduce and collect data"
    echo "  2. ANALYZE - Examine code and identify patterns"
    echo "  3. HYPOTHESIZE - Form and test hypothesis"
    echo "  4. IMPLEMENT - Fix root cause with regression test"
    echo ""
    exit 1
fi

BUG_DESC="$@"
DEBUG_ID=$(date +%s)
DEBUG_FILE=".em-skill/debug-$DEBUG_ID.md"

mkdir -p .em-skill

cat > "$DEBUG_FILE" << EOF
# Debug Session: $BUG_DESC

**ID:** $DEBUG_ID
**Started:** $(date)
**Status:** INVESTIGATE

## Bug Description
$BUG_DESC

---

## Phase 1: INVESTIGATE 📋

### Reproduction Steps
1.
2.
3.

### Scope
- Affected components:
- Affected users:
- Frequency:
- First observed:

### Data Collection
\`\`\`
# Relevant logs
\`\`\`

\`\`\`
# Stack traces
\`\`\`

\`\`\`
# Error messages
\`\`\`

### Investigation Notes
- What happens:
- What should happen:
- When it happens:
- Environment details:

---

## Phase 2: ANALYZE 🔍

### Code Paths
List relevant code paths:

### Data Flow
Trace data through the system:

### Patterns
Look for patterns in the data:

### Analysis Notes
- Similar bugs:
- Recent changes:
- Correlations:

---

## Phase 3: HYPOTHESIZE 💡

### Hypothesis
Write your hypothesis here:

### Test Plan
How to verify the hypothesis:

### Test Results
- Expected:
- Actual:
- Conclusion:

### Root Cause
**ROOT CAUSE:** (fill when confirmed)

---

## Phase 4: IMPLEMENT 🔧

### Fix Description
How to fix the root cause:

### Implementation
\`\`\`
// Code changes
\`\`\`

### Regression Test
\`\`\`
// Test to prevent this bug
\`\`\`

### Verification
- Fix verified: [ ]
- Regression test added: [ ]
- No side effects: [ ]

---

## Resolution
**Status:** OPEN
**Root Cause:** TBD
**Fix:** TBD
**Resolved:** TBD

---

## Iron Law Reminder
> NO FIXES WITHOUT ROOT CAUSE

Do not implement fixes without confirming the root cause.
Symptom fixes are temporary; root cause fixes are permanent.

EOF

echo "✓ Debug session created: $DEBUG_FILE"
echo ""
echo "🐛 Starting systematic debug session..."
echo ""
echo "Phase 1: INVESTIGATE"
echo "  - Reproduce the bug"
echo "  - Collect logs and data"
echo "  - Document findings"
echo ""
echo "When ready for next phase, run:"
echo "  em-skill debug-analyze $DEBUG_ID"
echo "  em-skill debug-hypothesize $DEBUG_ID"
echo "  em-skill debug-fix $DEBUG_ID"
