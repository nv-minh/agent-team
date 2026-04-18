#!/bin/bash
#
# EM-Skill Verify Command
# Source: GSD verification workflow
#
# Verify built features against spec and requirements
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}✅ EM-Skill Verification${NC}"
echo "======================="
echo ""

# Check for spec file
SPEC_FILE="SPEC.md"
if [ ! -f "$SPEC_FILE" ]; then
    echo -e "${YELLOW}⚠ No SPEC.md found in current directory${NC}"
    echo ""
    echo "Usage: em-skill verify [spec-file]"
    echo ""
    echo "This verifies implementation against spec:"
    echo "  - Checks all objectives are met"
    echo "  - Validates commands are implemented"
    echo "  - Confirms structure follows conventions"
    echo "  - Verifies code style compliance"
    echo "  - Checks testing strategy"
    echo "  - Ensures boundaries are respected"
    echo ""
    read -p "Continue without spec? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    SPEC_FILE=""
fi

VERIFY_ID=$(date +%s)
VERIFY_FILE=".em-skill/verify-$VERIFY_ID.md"

mkdir -p .em-skill

if [ -n "$SPEC_FILE" ]; then
    echo "Spec file: $SPEC_FILE"
    echo ""
fi

cat > "$VERIFY_FILE" << EOF
# Verification Report

**ID:** $VERIFY_ID
**Date:** $(date)
**Spec:** ${SPEC_FILE:-"No spec"}

---

## Verification Checklist

### 1. Objectives ✅

EOF

if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
    # Extract objectives from spec
    echo "Extracting objectives from spec..."
    grep -A 10 "## Objective" "$SPEC_FILE" | head -20 >> "$VERIFY_FILE"
else
    echo "No spec file - listing implementation..." >> "$VERIFY_FILE"
fi

cat >> "$VERIFY_FILE" << EOF

**Status:** NOT VERIFIED
**Notes:**

---

### 2. Commands / API Endpoints 🔧

EOF

if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
    echo "Extracting commands from spec..."
    grep -A 20 "## Commands" "$SPEC_FILE" | head -30 >> "$VERIFY_FILE"
fi

cat >> "$VERIFY_FILE" << EOF

**Status:** NOT VERIFIED
**Notes:**

---

### 3. Project Structure 📁

EOF

if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
    echo "Extracting structure from spec..."
    grep -A 30 "## Project Structure" "$SPEC_FILE" | head -40 >> "$VERIFY_FILE"
fi

cat >> "$VERIFY_FILE" << EOF

**Actual Structure:**
\`\`\`
$(find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | grep -v node_modules | head -20)
\`\`\`

**Status:** NOT VERIFIED
**Notes:**

---

### 4. Code Style 🎨

EOF

if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
    echo "Extracting style from spec..."
    grep -A 20 "## Code Style" "$SPEC_FILE" | head -25 >> "$VERIFY_FILE"
fi

cat >> "$VERIFY_FILE" << EOF

**Verification:**
- [ ] TypeScript strict mode (if applicable)
- [ ] Linting passes
- [ ] Formatting consistent
- [ ] Naming conventions followed

**Status:** NOT VERIFIED
**Notes:**

---

### 5. Testing Strategy 🧪

EOF

if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
    echo "Extracting testing from spec..."
    grep -A 30 "## Testing Strategy" "$SPEC_FILE" | head -35 >> "$VERIFY_FILE"
fi

cat >> "$VERIFY_FILE" << EOF

**Actual Coverage:**
\`\`\`
$(npm run test:coverage 2>/dev/null || echo "Coverage report not available")
\`\`\`

**Verification:**
- [ ] Unit tests written
- [ ] Integration tests written
- [ ] E2E tests written (if applicable)
- [ ] Coverage target met (>80%)

**Status:** NOT VERIFIED
**Notes:**

---

### 6. Boundaries 🚧

EOF

if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
    echo "Extracting boundaries from spec..."
    grep -A 20 "## Boundaries" "$SPEC_FILE" | head -25 >> "$VERIFY_FILE"
fi

cat >> "$VERIFY_FILE" << EOF

**Verification:**
- [ ] No scope creep
- [ ] Out-of-scope items not implemented
- [ ] Dependencies justified

**Status:** NOT VERIFIED
**Notes:**

---

## Requirements Verification

### Functional Requirements
- [ ] All features implemented
- [ ] All edge cases handled
- [ ] User workflows complete

### Non-Functional Requirements
- [ ] Performance targets met
- [ ] Security requirements met
- [ ] Accessibility requirements met
- [ ] Reliability requirements met

---

## Quality Gates

- [ ] All tests pass
- [ ] Linting passes
- [ ] Build succeeds
- [ ] No critical issues
- [ ] Documentation updated

---

## Gaps Identified

List any gaps between spec and implementation:

1.
2.
3.

---

## Recommendations

1.
2.
3.

---

## Final Decision

- [ ] **APPROVED** - Meets all requirements, ready to ship
- [ ] **CONDITIONAL** - Minor issues, can be addressed post-ship
- [ ] **REJECTED** - Critical issues, must be fixed

**Reasoning:**

---

EOF

echo "✓ Verification document created: $VERIFY_FILE"
echo ""
echo "✅ Starting verification process..."
echo ""

if [ -n "$SPEC_FILE" ]; then
    echo "To run verification, invoke the verifier agent:"
    echo ""
    echo '  "Agent: verifier - Verify the implementation against '$SPEC_FILE'"'
else
    echo "To run verification, invoke the verifier agent:"
    echo ""
    echo '  "Agent: verifier - Verify the implementation"'
fi

echo ""
echo "This will:"
echo "  - Check spec objectives are met"
echo "  - Verify all commands/endpoints implemented"
echo "  - Validate project structure"
echo "  - Confirm code style compliance"
echo "  - Check testing coverage"
echo "  - Ensure boundaries respected"
echo "  - Generate final report"
