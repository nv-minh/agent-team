#!/bin/bash
#
# EM-Skill Ship Command
# Source: GSD ship workflow
#
# Complete ship workflow: test, review, bump version, update changelog, commit, push, PR
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚢 EM-Skill Ship Workflow${NC}"
echo "========================="
echo ""

# Check git status
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠ Uncommitted changes detected${NC}"
    echo "Please commit or stash changes before shipping"
    git status --short
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Check if on main/master
if [[ "$CURRENT_BRANCH" =~ ^(main|master)$ ]]; then
    echo -e "${YELLOW}⚠ Warning: On main/master branch${NC}"
    echo "Ship workflow is for feature branches"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for base branch updates
echo "📥 Checking for base branch updates..."
BASE_BRANCH=${BASE_BRANCH:-main}
git fetch origin "$BASE_BRANCH" >/dev/null 2>&1

if git rev-parse --verify "origin/$BASE_BRANCH" >/dev/null 2>&1; then
    BEHIND_COUNT=$(git rev-list --count HEAD..origin/$BASE_BRANCH 2>/dev/null || echo 0)
    if [ "$BEHIND_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Base branch has $BEHIND_COUNT new commits${NC}"
        echo "Consider merging latest changes"
        read -p "Merge now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Merging $BASE_BRANCH..."
            git merge "origin/$BASE_BRANCH" --no-edit
        fi
    else
        echo -e "${GREEN}✓ Base branch up to date${NC}"
    fi
fi
echo ""

# Create ship document
SHIP_ID=$(date +%s)
SHIP_FILE=".em-skill/ship-$SHIP_ID.md"

mkdir -p .em-skill

cat > "$SHIP_FILE" << EOF
# Ship Workflow

**ID:** $SHIP_ID
**Date:** $(date)
**Branch:** $CURRENT_BRANCH
**Base:** $BASE_BRANCH

---

## Pre-Ship Checklist

### Code Quality
- [ ] All tests pass
- [ ] Linting passes
- [ ] Build succeeds
- [ ] No console errors
- [ ] Code reviewed

### Documentation
- [ ] README updated (if needed)
- [ ] CHANGELOG updated
- [ ] API docs updated (if applicable)
- [ ] Migration guide (if breaking)

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] Manual testing done

### Security
- [ ] No secrets committed
- [ ] Dependencies audited
- [ ] Security review done (if applicable)

---

## Version Bump

Current version: \$(cat VERSION 2>/dev/null || echo "0.0.0")

### Semantic Versioning
- **MAJOR:** Breaking changes
- **MINOR:** New features (backwards compatible)
- **PATCH:** Bug fixes (backwards compatible)

### Changes in this ship
List changes to determine version bump:

1.
2.
3.

### Proposed Version
New version: TBD

---

## Changelog

### [UNRELEASED]

### Added
- New features

### Changed
- Changes to existing features

### Deprecated
- Features that will be removed

### Removed
- Features removed in this release

### Fixed
- Bug fixes

### Security
- Security improvements

---

## PR Template

**Title:** ship: Prepare for vVERSION

**Description:**
Preparing for release of vVERSION

**Changes:**
- Version bump to vVERSION
- Update CHANGELOG
- Update documentation

**Testing:**
- [ ] Tests pass
- [ ] Manual testing done

**Breaking Changes:**
List breaking changes (if any):

---

## Ship Steps

1. **Run tests:** \`npm test\`
2. **Run lint:** \`npm run lint\`
3. **Build:** \`npm run build\`
4. **Bump version:** Update VERSION file
5. **Update CHANGELOG:** Add release notes
6. **Commit:** Create ship commit
7. **Create PR:** Against $BASE_BRANCH
8. **Merge:** After approval

---

## Status
**Current:** READY
**Next:** Run tests

EOF

echo "✓ Ship document created: $SHIP_FILE"
echo ""
echo "🚢 Starting ship workflow..."
echo ""
echo "Step 1: Run tests"
echo "  npm test"
echo ""
echo "Step 2: Run linter"
echo "  npm run lint"
echo ""
echo "Step 3: Build"
echo "  npm run build"
echo ""
echo "Step 4: Bump version"
echo "  # Update VERSION file"
echo "  # Update CHANGELOG.md"
echo ""
echo "Step 5: Create PR"
echo "  gh pr create --title 'ship: Prepare for vX.X.X' --body 'Prepare for release'"
echo ""
echo "Or invoke ship agent:"
echo '  "Agent: ship - Create PR, run review, prepare for merge"'
echo ""
echo "Quick ship (auto mode):"
echo "  em-skill ship-auto"
