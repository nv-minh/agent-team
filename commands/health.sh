#!/bin/bash
#
# EM-Team Health Command
# Source: GSD project health check
#
# Diagnose project health and identify issues
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏥 EM-Team Health Check${NC}"
echo "======================="
echo ""

HEALTH_ID=$(date +%s)
HEALTH_FILE=".em-team/health-$HEALTH_ID.md"
SCORE=0
MAX_SCORE=0

mkdir -p .em-team

# Function to add score
add_score() {
    local points=$1
    local max=$2
    SCORE=$((SCORE + points))
    MAX_SCORE=$((MAX_SCORE + max))
}

echo "Running health checks..."
echo ""

# 1. Git Status
echo -n "📂 Git repository... "
if git rev-parse --git-dir >/dev/null 2>&1; then
    if [ -z "$(git status --porcelain)" ]; then
        echo -e "${GREEN}Clean${NC}"
        add_score 10 10
    else
        echo -e "${YELLOW}Uncommitted changes${NC}"
        add_score 5 10
    fi
else
    echo -e "${RED}Not a git repository${NC}"
    add_score 0 10
fi

# 2. Package Manager
echo -n "📦 Package manager... "
if [ -f "package.json" ]; then
    if [ -d "node_modules" ]; then
        echo -e "${GREEN}Dependencies installed${NC}"
        add_score 10 10
    else
        echo -e "${YELLOW}Dependencies not installed${NC}"
        add_score 0 10
    fi
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo -e "${GREEN}Python project${NC}"
    add_score 10 10
elif [ -f "go.mod" ]; then
    echo -e "${GREEN}Go module${NC}"
    add_score 10 10
else
    echo -e "${YELLOW}Unknown package manager${NC}"
    add_score 5 10
fi

# 3. Testing
echo -n "🧪 Tests... "
if [ -f "package.json" ]; then
    if npm run test 2>/dev/null >/dev/null; then
        echo -e "${GREEN}Tests pass${NC}"
        add_score 15 15
    else
        echo -e "${RED}Tests fail or not found${NC}"
        add_score 0 15
    fi
else
    echo -e "${YELLOW}No tests configured${NC}"
    add_score 0 15
fi

# 4. Linting
echo -n "🔍 Linting... "
if [ -f "package.json" ]; then
    if npm run lint 2>/dev/null >/dev/null; then
        echo -e "${GREEN}Clean${NC}"
        add_score 10 10
    else
        echo -e "${YELLOW}Lint issues or not configured${NC}"
        add_score 5 10
    fi
else
    echo -e "${YELLOW}No linter configured${NC}"
    add_score 0 10
fi

# 5. Build
echo -n "🔨 Build... "
if [ -f "package.json" ]; then
    if npm run build 2>/dev/null >/dev/null; then
        echo -e "${GREEN}Build succeeds${NC}"
        add_score 10 10
    else
        echo -e "${YELLOW}Build fails or not configured${NC}"
        add_score 5 10
    fi
else
    echo -e "${YELLOW}No build configured${NC}"
    add_score 0 10
fi

# 6. Documentation
echo -n "📚 Documentation... "
if [ -f "README.md" ]; then
    if [ -f "SPEC.md" ] || [ -f "docs/" ]; then
        echo -e "${GREEN}Well documented${NC}"
        add_score 10 10
    else
        echo -e "${YELLOW}Basic documentation${NC}"
        add_score 5 10
    fi
else
    echo -e "${RED}No documentation${NC}"
    add_score 0 10
fi

# 7. Dependencies
echo -n "🔒 Dependencies... "
if [ -f "package.json" ]; then
    if npm audit --production --audit-level high >/dev/null 2>&1; then
        echo -e "${GREEN}No high/critical vulnerabilities${NC}"
        add_score 10 10
    else
        echo -e "${RED}Vulnerabilities found${NC}"
        add_score 0 10
    fi
else
    echo -e "${YELLOW}Skipped${NC}"
    add_score 5 10
fi

# 8. Git Hooks
echo -n "🪝 Git hooks... "
if [ -f ".git/hooks/pre-commit" ]; then
    echo -e "${GREEN}Installed${NC}"
    add_score 10 10
else
    echo -e "${YELLOW}Not installed${NC}"
    add_score 0 10
fi

# 9. CI/CD
echo -n "🚀 CI/CD... "
if [ -d ".github/workflows" ] || [ -f ".gitlab-ci.yml" ] || [ -f "Jenkinsfile" ]; then
    echo -e "${GREEN}Configured${NC}"
    add_score 10 10
else
    echo -e "${YELLOW}Not configured${NC}"
    add_score 0 10
fi

# 10. EM-Team Integration
echo -n "⚡ EM-Team... "
if [ -f "CLAUDE.md" ] || [ -d ".em-team" ]; then
    echo -e "${GREEN}Integrated${NC}"
    add_score 5 5
else
    echo -e "${YELLOW}Not integrated${NC}"
    add_score 0 5
fi

echo ""
echo "======================="

# Calculate percentage
if [ $MAX_SCORE -gt 0 ]; then
    PERCENTAGE=$((SCORE * 100 / MAX_SCORE))
else
    PERCENTAGE=0
fi

# Display score
echo ""
echo "Health Score: $SCORE / $MAX_SCORE ($PERCENTAGE%)"

if [ $PERCENTAGE -ge 80 ]; then
    echo -e "${GREEN}✅ Excellent health!${NC}"
    STATUS="Excellent"
elif [ $PERCENTAGE -ge 60 ]; then
    echo -e "${YELLOW}⚠️  Good health, room for improvement${NC}"
    STATUS="Good"
elif [ $PERCENTAGE -ge 40 ]; then
    echo -e "${YELLOW}⚠️  Fair health, needs attention${NC}"
    STATUS="Fair"
else
    echo -e "${RED}❌ Poor health, critical issues${NC}"
    STATUS="Poor"
fi

echo ""

# Generate report
cat > "$HEALTH_FILE" << EOF
# Health Check Report

**ID:** $HEALTH_ID
**Date:** $(date)
**Score:** $SCORE / $MAX_SCORE ($PERCENTAGE%)
**Status:** $STATUS

---

## Detailed Results

### 📂 Git Repository
$(git rev-parse --git-dir >/dev/null 2>&1 && echo "✓ Git repository initialized" || echo "✗ Not a git repository")

### 📦 Package Manager
$(test -f package.json && echo "✓ package.json found" || echo "✗ No package.json")

### 🧪 Tests
$(npm run test 2>/dev/null >/dev/null && echo "✓ Tests pass" || echo "✗ Tests fail or not configured")

### 🔍 Linting
$(npm run lint 2>/dev/null >/dev/null && echo "✓ Linting clean" || echo "⚠ Lint issues or not configured")

### 🔨 Build
$(npm run build 2>/dev/null >/dev/null && echo "✓ Build succeeds" || echo "⚠ Build fails or not configured")

### 📚 Documentation
$(test -f README.md && echo "✓ README.md present" || echo "✗ No documentation")

### 🔒 Dependencies
$(npm audit --production --audit-level high >/dev/null 2>&1 && echo "✓ No high/critical vulnerabilities" || echo "✗ Vulnerabilities found")

### 🪝 Git Hooks
$(test -f .git/hooks/pre-commit && echo "✓ Git hooks installed" || echo "⚠ Git hooks not installed")

### 🚀 CI/CD
$(test -d .github/workflows && echo "✓ CI/CD configured" || echo "⚠ CI/CD not configured")

### ⚡ EM-Team
$(test -f CLAUDE.md && echo "✓ EM-Team integrated" || echo "⚠ EM-Team not integrated")

---

## Recommendations

EOF

# Add recommendations based on score
if [ ! -f ".git/hooks/pre-commit" ]; then
    echo "- Install git hooks for quality enforcement" >> "$HEALTH_FILE"
fi

if [ ! -d ".github/workflows" ]; then
    echo "- Setup CI/CD pipeline for automated testing" >> "$HEALTH_FILE"
fi

if ! npm run test 2>/dev/null >/dev/null; then
    echo "- Add or fix tests to improve code quality" >> "$HEALTH_FILE"
fi

if ! npm run lint 2>/dev/null >/dev/null; then
    echo "- Configure and run linter" >> "$HEALTH_FILE"
fi

if [ ! -f "README.md" ]; then
    echo "- Add README.md documentation" >> "$HEALTH_FILE"
fi

cat >> "$HEALTH_FILE" << EOF

---

## Quick Fixes

### Install Git Hooks
\`\`\`bash
cp em-team/hooks/* .git/hooks/
chmod +x .git/hooks/*
\`\`\`

### Setup EM-Team
\`\`\`bash
cp em-team/CLAUDE.md ./
\`\`\`

### Run Full Test Suite
\`\`\`bash
npm test
\`\`\`

---

EOF

echo "✓ Health report saved: $HEALTH_FILE"
echo ""
echo "To improve health, consider:"
echo "  - Install git hooks: cp em-team/hooks/* .git/hooks/"
echo "  - Setup CI/CD: Add .github/workflows/"
echo "  - Add tests: npm run test"
echo "  - Add documentation: Create README.md"
