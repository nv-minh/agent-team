#!/bin/bash
#
# EM-Team QA Command
# Source: gstack browser testing + QA automation
#
# Systematically QA test a web application
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 EM-Team QA Testing${NC}"
echo "======================"
echo ""

# Check for URL
if [ -z "$1" ]; then
    echo "Usage: em-team qa <url-or-path> [scope]"
    echo ""
    echo "Examples:"
    echo "  em-team qa http://localhost:3000"
    echo "  em-team qa https://staging.example.com"
    echo "  em-team qa /dashboard critical"
    echo ""
    echo "Scopes:"
    echo "  full    - Complete QA test suite (default)"
    echo "  critical- Critical user paths only"
    echo "  smoke   - Smoke test (basic functionality)"
    echo "  visual  - Visual regression only"
    echo ""
    echo "This will:"
    echo "  - Launch browser (headless or visible)"
    echo "  - Test critical paths"
    echo "  - Check for console errors"
    echo "  - Verify responsive design"
    echo "  - Generate QA report"
    echo ""
    exit 1
fi

URL="$1"
SCOPE="${2:-full}"
QA_ID=$(date +%s)
QA_FILE=".em-team/qa-$QA_ID.md"

mkdir -p .em-team

cat > "$QA_FILE" << EOF
# QA Test Report

**ID:** $QA_ID
**Date:** $(date)
**URL:** $URL
**Scope:** $SCOPE

---

## Test Environment
- **URL:** $URL
- **Browser:** Chromium (Headless)
- **Viewport:** Mobile, Tablet, Desktop
- **Started:** $(date)

---

## Test Results

### Critical Paths 🎯

#### Authentication
- [ ] Login works
- [ ] Logout works
- [ ] Password reset works
- [ ] Registration works

**Status:** NOT TESTED
**Issues:** None

---

#### Core Features
- [ ] Create resource
- [ ] Read resource
- [ ] Update resource
- [ ] Delete resource

**Status:** NOT TESTED
**Issues:** None

---

### Technical Checks 🔍

#### Console Errors
- [ ] No console errors
- [ ] No console warnings
- [ ] No network failures

**Status:** NOT TESTED
**Issues:** None

---

#### Performance
- [ ] Page load < 3s
- [ ] Time to Interactive < 5s
- [ ] No layout shifts
- [ ] Images optimized

**Status:** NOT TESTED
**Issues:** None

---

#### Responsive Design
- [ ] Mobile (375px)
- [ ] Tablet (768px)
- [ ] Desktop (1440px)

**Status:** NOT TESTED
**Issues:** None

---

### Visual QA 👁️

#### Design Consistency
- [ ] Typography consistent
- [ ] Colors match design system
- [ ] Spacing consistent
- [ ] Icons correct

**Status:** NOT TESTED
**Issues:** None

---

#### Accessibility
- [ ] ARIA labels present
- [ ] Keyboard navigation works
- [ ] Color contrast sufficient
- [ ] Focus indicators visible

**Status:** NOT TESTED
**Issues:** None

---

## Summary

### Health Score
**Overall:** TBD / 100

### By Category
- Critical Paths: TBD / 100
- Technical: TBD / 100
- Performance: TBD / 100
- Visual: TBD / 100
- Accessibility: TBD / 100

### Blocking Issues
List issues that block deployment:

### Critical Issues
List issues that should be fixed soon:

### Minor Issues
List cosmetic or low-priority issues:

### Positive Findings
What works well:

---

## Screenshots
Screenshots will be captured during testing.

---

## Recommendations
1.
2.
3.

EOF

echo "✓ QA report created: $QA_FILE"
echo ""
echo "🧪 Starting QA test session..."
echo ""
echo "To run QA testing, invoke:"
echo '  "Agent: qa - Systematically QA test the application at '$URL'"'
echo ""
echo "Or use browser-testing skill:"
echo '  "Use browser-testing skill to test '$URL'"'
echo ""
echo "This will:"
echo "  - Launch browser"
echo "  - Navigate to $URL"
echo "  - Test critical paths"
echo "  - Check for errors"
echo "  - Take screenshots"
echo "  - Generate report"
