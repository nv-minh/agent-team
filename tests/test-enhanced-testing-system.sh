#!/bin/bash
# Enhanced Testing System - Evaluation Script
# Validates all 3 new capabilities with 28 test cases
# Pass threshold: ≥90% (25/28 tests pass)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
TOTAL=28

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass_test() {
  PASS=$((PASS + 1))
  echo -e "  ${GREEN}PASS${NC} $1"
}

fail_test() {
  FAIL=$((FAIL + 1))
  echo -e "  ${RED}FAIL${NC} $1 — $2"
}

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Enhanced Testing System — Evaluation"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─── Group 1: Test Generation ───────────────────────────────
echo "── Group 1: Test Generation Effectiveness ──"

TG="$PROJECT_ROOT/skills/quality/test-generation/test-generation.md"

# TC-EVAL-001: YAML frontmatter has all required fields
FIELDS=("name:" "description:" "version:" "category:" "origin:" "tools:" "triggers:" "intent:" "scenarios:" "best_for:" "anti_patterns:" "related_skills:")
MISSING=""
for field in "${FIELDS[@]}"; do
  if ! grep -q "$field" "$TG"; then
    MISSING="$MISSING $field"
  fi
done
if [ -z "$MISSING" ]; then
  pass_test "TC-EVAL-001: test-generation YAML frontmatter has all required fields"
else
  fail_test "TC-EVAL-001: test-generation YAML frontmatter missing:$MISSING"
fi

# TC-EVAL-002: Test case template contains all structured fields
TEMPLATE_FIELDS=("TC-ID" "Expected Output" "Actual Output" "Pass/Fail" "Input" "Priority")
MISSING=""
for field in "${TEMPLATE_FIELDS[@]}"; do
  if ! grep -q "$field" "$TG"; then
    MISSING="$MISSING $field"
  fi
done
if [ -z "$MISSING" ]; then
  pass_test "TC-EVAL-002: Test case template contains all structured fields"
else
  fail_test "TC-EVAL-002: Template missing:$MISSING"
fi

# TC-EVAL-003: Generation workflow has 5 steps
if grep -q "ANALYZE" "$TG" && grep -q "MAP BRANCHES" "$TG" && grep -q "GENERATE CASES" "$TG" && grep -q "WRITE TESTS" "$TG" && grep -q "VALIDATE" "$TG"; then
  pass_test "TC-EVAL-003: Generation workflow has 5 steps (ANALYZE → MAP BRANCHES → GENERATE CASES → WRITE TESTS → VALIDATE)"
else
  fail_test "TC-EVAL-003: Generation workflow missing steps"
fi

# TC-EVAL-004: Edge case discovery covers all categories
EDGE_CATS=("null" "empty" "boundary" "type" "concurrent" "error")
MISSING=""
for cat in "${EDGE_CATS[@]}"; do
  if ! grep -qi "$cat" "$TG"; then
    MISSING="$MISSING $cat"
  fi
done
if [ -z "$MISSING" ]; then
  pass_test "TC-EVAL-004: Edge case discovery covers all categories"
else
  fail_test "TC-EVAL-004: Missing edge case categories:$MISSING"
fi

# TC-EVAL-005: Test code templates exist for unit, integration, and E2E levels
if grep -q "Unit Test" "$TG" && grep -q "Integration Test" "$TG" && grep -q "E2E Test" "$TG"; then
  pass_test "TC-EVAL-005: Test code templates exist for unit, integration, and E2E levels"
else
  fail_test "TC-EVAL-005: Missing test code templates"
fi

# TC-EVAL-006: SKILL-INDEX count is 73
INDEX="$PROJECT_ROOT/skills/SKILL-INDEX.md"
if grep -q "73 skills" "$INDEX" && grep -q "73 Skills" "$INDEX"; then
  pass_test "TC-EVAL-006: SKILL-INDEX count is 73"
else
  fail_test "TC-EVAL-006: SKILL-INDEX count mismatch"
fi

# TC-EVAL-007: SKILL.md symlink resolves correctly
SYMLINK="$PROJECT_ROOT/skills/quality/test-generation/SKILL.md"
if [ -L "$SYMLINK" ] && [ -e "$SYMLINK" ]; then
  pass_test "TC-EVAL-007: SKILL.md symlink resolves correctly"
else
  fail_test "TC-EVAL-007: SKILL.md symlink broken or missing"
fi

echo ""

# ─── Group 2: Video Recording ───────────────────────────────
echo "── Group 2: Video Recording Effectiveness ──"

BT="$PROJECT_ROOT/skills/quality/browser-testing/browser-testing.md"

# TC-EVAL-008: browser-testing version is 3.0.0
if grep -q 'version: "3.0.0"' "$BT" || grep -q "version: '3.0.0'" "$BT"; then
  pass_test "TC-EVAL-008: browser-testing version is 3.0.0"
else
  fail_test "TC-EVAL-008: browser-testing version is not 3.0.0"
fi

# TC-EVAL-009: recordVideo code example exists
if grep -q "recordVideo" "$BT"; then
  pass_test "TC-EVAL-009: recordVideo code example exists in browser-testing"
else
  fail_test "TC-EVAL-009: recordVideo not found"
fi

# TC-EVAL-010: TestEvidence interface exists
if grep -q "TestEvidence" "$BT"; then
  pass_test "TC-EVAL-010: TestEvidence interface definition exists"
else
  fail_test "TC-EVAL-010: TestEvidence interface not found"
fi

# TC-EVAL-011: Evidence directory structure documented
if grep -q "test-results/videos" "$BT" && grep -q "test-results/screenshots" "$BT" && grep -q "test-results/traces" "$BT"; then
  pass_test "TC-EVAL-011: Evidence directory structure documented"
else
  fail_test "TC-EVAL-011: Evidence directory structure incomplete"
fi

# TC-EVAL-012: HTML evidence report with video tag
if grep -q "<video" "$BT"; then
  pass_test "TC-EVAL-012: HTML evidence report has <video> tag"
else
  fail_test "TC-EVAL-012: HTML evidence report missing video tag"
fi

# TC-EVAL-013: Save video on failure pattern
if grep -q "video.saveAs" "$BT" && grep -q "test.afterEach\|afterEach" "$BT"; then
  pass_test "TC-EVAL-013: Save video on failure pattern exists"
else
  fail_test "TC-EVAL-013: Save video on failure pattern incomplete"
fi

# TC-EVAL-014: Combined evidence pattern documented
if grep -q "screenshot" "$BT" && grep -q "video" "$BT" && grep -q "trace" "$BT"; then
  pass_test "TC-EVAL-014: Combined evidence pattern (screenshot + video + trace) documented"
else
  fail_test "TC-EVAL-014: Combined evidence pattern incomplete"
fi

echo ""

# ─── Group 3: API Contract + Timing ─────────────────────────
echo "── Group 3: API Contract + Timing Effectiveness ──"

AT="$PROJECT_ROOT/skills/quality/api-testing/api-testing.md"

# TC-EVAL-015: api-testing version is 3.0.0
if grep -q 'version: "3.0.0"' "$AT" || grep -q "version: '3.0.0'" "$AT"; then
  pass_test "TC-EVAL-015: api-testing version is 3.0.0"
else
  fail_test "TC-EVAL-015: api-testing version is not 3.0.0"
fi

# TC-EVAL-016: APIContract interface exists with all fields
if grep -q "APIContract" "$AT" && grep -q "endpoint" "$AT" && grep -q "method" "$AT" && grep -q "request" "$AT" && grep -q "expected" "$AT" && grep -q "actual" "$AT" && grep -q "result" "$AT"; then
  pass_test "TC-EVAL-016: APIContract interface exists with all fields"
else
  fail_test "TC-EVAL-016: APIContract interface incomplete"
fi

# TC-EVAL-017: maxResponseTime field in expected contract
if grep -q "maxResponseTime" "$AT"; then
  pass_test "TC-EVAL-017: maxResponseTime field exists in expected contract"
else
  fail_test "TC-EVAL-017: maxResponseTime not found"
fi

# TC-EVAL-018: responseTime field in actual contract
if grep -q "responseTime" "$AT"; then
  pass_test "TC-EVAL-018: responseTime field exists in actual contract"
else
  fail_test "TC-EVAL-018: responseTime not found"
fi

# TC-EVAL-019: Percentile thresholds (P50, P95, P99)
if grep -q "p50" "$AT" && grep -q "p95" "$AT" && grep -q "p99" "$AT"; then
  pass_test "TC-EVAL-019: Percentile threshold pattern exists (P50, P95, P99)"
else
  fail_test "TC-EVAL-019: Percentile thresholds incomplete"
fi

# TC-EVAL-020: BenchmarkResult interface exists
if grep -q "BenchmarkResult" "$AT"; then
  pass_test "TC-EVAL-020: BenchmarkResult interface exists"
else
  fail_test "TC-EVAL-020: BenchmarkResult not found"
fi

# TC-EVAL-021: benchmarkEndpoint function pattern exists
if grep -q "benchmarkEndpoint" "$AT"; then
  pass_test "TC-EVAL-021: benchmarkEndpoint() function pattern exists"
else
  fail_test "TC-EVAL-021: benchmarkEndpoint not found"
fi

# TC-EVAL-022: Benchmark report format documented
if grep -q "Benchmark Report" "$AT" || grep -q "Benchmark Report" "$AT"; then
  pass_test "TC-EVAL-022: Benchmark report format documented"
else
  fail_test "TC-EVAL-022: Benchmark report format not found"
fi

echo ""

# ─── Group 4: Agent Integration ─────────────────────────────
echo "── Group 4: Agent Integration ──"

TE="$PROJECT_ROOT/agents/test-engineer.md"

# TC-EVAL-023: test-engineer version is 2.0.0
if grep -q "version: 2.0.0" "$TE" || grep -q 'version: "2.0.0"' "$TE"; then
  pass_test "TC-EVAL-023: test-engineer version is 2.0.0"
else
  fail_test "TC-EVAL-023: test-engineer version is not 2.0.0"
fi

# TC-EVAL-024: Agent has auto-generation capability
if grep -qi "auto-generation\|auto_generation" "$TE"; then
  pass_test "TC-EVAL-024: Agent has auto-generation capability listed"
else
  fail_test "TC-EVAL-024: Auto-generation capability not found"
fi

# TC-EVAL-025: Agent references test-generation skill
if grep -q "test-generation" "$TE"; then
  pass_test "TC-EVAL-025: Agent references test-generation skill"
else
  fail_test "TC-EVAL-025: test-generation reference not found"
fi

# TC-EVAL-026: Agent has video recording strategy section
if grep -qi "Video Recording Strategy\|video recording" "$TE"; then
  pass_test "TC-EVAL-026: Agent has video recording strategy section"
else
  fail_test "TC-EVAL-026: Video recording strategy not found"
fi

# TC-EVAL-027: Agent has API contract testing section
if grep -qi "API Contract\|api contract" "$TE"; then
  pass_test "TC-EVAL-027: Agent has API contract testing section"
else
  fail_test "TC-EVAL-027: API contract section not found"
fi

# TC-EVAL-028: Agent config has auto_from_source, video_recording, api_performance
if grep -q "auto_from_source" "$TE" && grep -q "video_recording" "$TE" && grep -q "api_performance" "$TE"; then
  pass_test "TC-EVAL-028: Agent config has auto_from_source, video_recording, api_performance"
else
  fail_test "TC-EVAL-028: Agent config settings incomplete"
fi

echo ""

# ─── Report ─────────────────────────────────────────────────
COVERAGE=$(( (PASS * 100) / TOTAL ))
G1_MAX=7 G2_MAX=7 G3_MAX=8 G4_MAX=6
# Approximate group scores from sequential pass count
echo "═══════════════════════════════════════════════════════════"
echo "  Enhanced Testing System — Evaluation Report"
echo "═══════════════════════════════════════════════════════════"
echo "  Total Tests:  $TOTAL"
echo "  Passed:       $PASS"
echo "  Failed:       $FAIL"
echo "  Coverage:     ${COVERAGE}%"
echo ""
echo "  Group 1 - Test Generation:     max $G1_MAX"
echo "  Group 2 - Video Recording:     max $G2_MAX"
echo "  Group 3 - API Contract/Timing: max $G3_MAX"
echo "  Group 4 - Agent Integration:   max $G4_MAX"
echo ""

if [ "$COVERAGE" -ge 90 ]; then
  echo -e "  Status: ${GREEN}PASS${NC} (≥90% threshold met)"
  echo "═══════════════════════════════════════════════════════════"
  exit 0
else
  echo -e "  Status: ${RED}FAIL${NC} (<90% threshold, need ≥25/28)"
  echo "═══════════════════════════════════════════════════════════"
  exit 1
fi
