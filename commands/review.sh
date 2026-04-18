#!/bin/bash
#
# EM-Skill Review Command
# Source: GSD + agent-skills code review
#
# Trigger 5-axis code review
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}👁️ EM-Skill Code Review${NC}"
echo "======================="
echo ""

# Function to show usage
show_usage() {
    echo "Usage:"
    echo "  em-skill review              # Review staged changes"
    echo "  em-skill review <branch>     # Review diff from branch"
    echo "  em-skill review <commit>     # Review specific commit"
    echo "  em-skill review --file <path> # Review specific file"
    echo ""
    echo "Examples:"
    echo "  em-skill review main         # Review changes from main branch"
    echo "  em-skill review HEAD~1       # Review last commit"
    echo "  em-skill review --file src/app.ts # Review specific file"
    exit 1
}

# Determine what to review
if [ -z "$1" ]; then
    # Review staged changes
    echo "Reviewing staged changes..."
    BASE=$(git diff --cached --name-only 2>/dev/null | wc -l)
    if [ "$BASE" -eq 0 ]; then
        echo -e "${YELLOW}ℹ️  No staged changes found${NC}"
        echo ""
        show_usage
    fi
    REVIEW_TARGET="staged"
    REVIEW_FILES=$(git diff --cached --name-only 2>/dev/null)
elif [ "$1" = "--file" ]; then
    # Review specific file
    if [ -z "$2" ]; then
        echo -e "${RED}❌ Error: --file requires a file path${NC}"
        echo ""
        show_usage
    fi
    if [ ! -f "$2" ]; then
        echo -e "${RED}❌ Error: File not found: $2${NC}"
        echo ""
        exit 1
    fi
    REVIEW_TARGET="--file"
    REVIEW_FILES="$2"
else
    # Review branch or commit
    REVIEW_TARGET="$1"
    REVIEW_FILES=$(git diff "$1" --name-only 2>/dev/null)
    if [ -z "$REVIEW_FILES" ]; then
        echo -e "${RED}❌ Error: No changes found compared to '$1'${NC}"
        echo ""
        echo "Possible causes:"
        echo "  - Branch/commit doesn't exist"
        echo "  - No differences from specified target"
        echo ""
        exit 1
    fi
fi

echo "Target: $REVIEW_TARGET"
echo ""
echo "Files to review:"
echo "$REVIEW_FILES" | sed 's/^/  - /'
echo ""

# Create review document
REVIEW_ID=$(date +%s)
REVIEW_FILE=".em-skill/review-$REVIEW_ID.md"

mkdir -p .em-skill

cat > "$REVIEW_FILE" << EOF
# Code Review Report

**ID:** $REVIEW_ID
**Date:** $(date)
**Target:** $REVIEW_TARGET
**Reviewer:** EM-Skill Code-Reviewer Agent

## 5-Axis Review Framework

---

### 1. CORRECTNESS ✅
**Question:** Does the code do what it's supposed to do?

**Checks:**
- [ ] Logic is correct
- [ ] Edge cases handled
- [ ] No obvious bugs
- [ ] Tests verify behavior
- [ ] No race conditions

**Findings:**

**Rating:** TBD / 5

---

### 2. READABILITY 📖
**Question:** Is the code easy to understand?

**Checks:**
- [ ] Clear naming
- [ ] Self-documenting code
- [ ] Appropriate comments
- [ ] No magic numbers
- [ ] Consistent style

**Findings:**

**Rating:** TBD / 5

---

### 3. ARCHITECTURE 🏗️
**Question:** Does it fit the system architecture?

**Checks:**
- [ ] Follows project conventions
- [ ] Proper abstraction level
- [ ] Single responsibility
- [ ] No code duplication
- [ ] Modularity maintained

**Findings:**

**Rating:** TBD / 5

---

### 4. SECURITY 🔒
**Question:** Are there security vulnerabilities?

**Checks:**
- [ ] Input validation
- [ ] No SQL injection
- [ ] No XSS vulnerabilities
- [ ] Proper authentication
- [ ] Proper authorization
- [ ] No secrets leaked

**Findings:**

**Rating:** TBD / 5

---

### 5. PERFORMANCE ⚡
**Question:** Are there performance issues?

**Checks:**
- [ ] Efficient algorithms
- [ ] No unnecessary queries
- [ ] Proper caching
- [ ] No memory leaks
- [ ] Scalable design

**Findings:**

**Rating:** TBD / 5

---

## Summary

### Overall Assessment
**Average Rating:** TBD / 5

### Must Fix (Blocking)
List issues that must be fixed before merge:

### Should Fix (Recommended)
List improvements strongly recommended:

### Nice to Have (Optional)
List optional improvements:

### Positive Highlights
What was done well:

---

## Decision
- [ ] APPROVED - Ready to merge
- [ ] REQUEST CHANGES - Fix must-fix issues
- [ ] COMMENT ONLY - Non-blocking feedback

---

## Action Items
1.
2.
3.

EOF

echo "✓ Review document created: $REVIEW_FILE"
echo ""
echo "To run the review, invoke the code-reviewer agent:"
echo ""
echo '  "Agent: code-reviewer - Review the changes in this PR"'
echo ""
echo "Or use:"
echo "  em-skill review-run $REVIEW_ID"
