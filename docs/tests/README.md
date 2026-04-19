# EM-Team Test Suite

Tổng quan test suite cho hệ thống EM-Team.

---

## Mục Lục

1. [Tổng quan](#tổng-quan)
2. [Test Categories](#test-categories)
3. [Running Tests](#running-tests)
4. [Test Structure](#test-structure)
5. [Coverage](#coverage)
6. [CI/CD Integration](#cicd-integration)

---

## Tổng quan

EM-Team có comprehensive test suite với:

- **20+ E2E Tests** - Test toàn bộ system
- **50+ Unit Tests** - Test individual functions
- **15+ Integration Tests** - Test component integration
- **TDD Auto-Retry** - Automatic test retry with exponential backoff

### Test Goals

```yaml
primary_goals:
  - Ensure system reliability
  - Catch regressions early
  - Validate new features
  - Maintain code quality

quality_gates:
  - 80%+ code coverage required
  - All E2E tests must pass
  - No critical bugs allowed
  - Performance benchmarks met
```

---

## Test Categories

### 1. End-to-End (E2E) Tests

**Purpose:** Test complete workflows and system integration

**Location:** `tests/e2e/`

**Key Tests:**

```bash
# Core functionality tests
test-core-commands.sh          # Test basic commands
test-agent-invocation.sh       # Test agent calls
test-workflow-execution.sh     # Test workflow runs
test-skill-activation.sh       # Test skill usage

# Distributed mode tests
test-distributed-orchestrator.sh    # Test distributed system
test-session-coordination.sh        # Test agent coordination
test-report-consolidation.sh        # Test report merging
test-token-management.sh            # Test token handling

# Feature-specific tests
test-tdd-auto-retry.sh        # Test TDD retry mechanism
test-token-summarization.sh   # Test token summarization
test-knowledge-persistence.sh # Test knowledge base

# Integration tests
test-mcp-integrations.sh      # Test MCP servers
test-git-integration.sh       # Test Git hooks
test-cli-completion.sh        # Test shell completion
```

**Example E2E Test:**

```bash
#!/usr/bin/env bash
# test-tdd-auto-retry.sh

test_tdd_retry_with_flaky_test() {
    # Arrange
    local test_script="$BATS_TMPDIR/flaky-test.sh"
    cat > "$test_script" <<EOF
#!/usr/bin/env bash
retry_count=\$1
if [ "\$retry_count" -lt 2 ]; then
  exit 1  # Fail first 2 times
else
  exit 0  # Pass on 3rd try
EOF
    chmod +x "$test_script"

    # Act
    run ./tests/tdd-retry-wrapper.sh run "$test_script" 3

    # Assert
    [ "$status" -eq 0 ]
    [ -f ".claude/tdd-context/test-retry-count.txt" ]
    [ "$(cat .claude/tdd-context/test-retry-count.txt)" -eq 3 ]
}
```

### 2. Unit Tests

**Purpose:** Test individual functions and components

**Location:** `tests/unit/`

**Key Tests:**

```bash
# Token counting tests
test-token-counter.sh
  ├─ test_estimate_tokens_with_tiktoken()
  ├─ test_estimate_tokens_fallback()
  ├─ test_check_threshold()
  └─ test_compare_to_budget()

# TDD context tests
test-tdd-context-manager.sh
  ├─ test_capture_error_context()
  ├─ test_save_to_json()
  ├─ test_load_context()
  └─ test_cleanup_context()

# Helper function tests
test-test-helpers.sh
  ├─ test_log_info()
  ├─ test_log_error()
  ├─ test_validate_test_command()
  └─ test_check_test_environment()
```

**Example Unit Test:**

```bash
#!/usr/bin/env bash
# test-token-counter.sh

@test "estimate tokens with tiktoken" {
    # Arrange
    local text="Hello, world!"
    local expected_tokens=3  # Approximately

    # Act
    result=$(./scripts/token-counter.sh estimate "$test_file")

    # Assert
    [ "$result" -ge 2 ]
    [ "$result" -le 4 ]
}

@test "check threshold correctly" {
    # Arrange
    local threshold=100
    echo "${large_text}" > "$test_file"

    # Act
    run ./scripts/token-counter.sh check "$test_file" $threshold

    # Assert
    [ "$status" -eq 0 ]  # Exceeds threshold
}
```

### 3. Integration Tests

**Purpose:** Test component interactions

**Location:** `tests/integration/`

**Key Tests:**

```bash
# Agent coordination tests
test-agent-handoff.sh
  ├─ test_planner_to_executor_handoff()
  ├─ test_executor_to_reviewer_handoff()
  └─ test_multi_agent_workflow()

# Distributed system tests
test-distributed-coordination.sh
  ├─ test_orchestrator_delegates_to_specialists()
  ├─ test_specialists_report_back()
  └─ test_consolidation_merges_reports()

# Knowledge persistence tests
test-knowledge-integration.sh
  ├─ test_codebase_mapper_extracts_conventions()
  ├─ test_agents_load_knowledge()
  └─ test_knowledge_applied_to_work()
```

**Example Integration Test:**

```bash
#!/usr/bin/env bash
# test-agent-handoff.sh

@test "planner to executor handoff" {
    # Arrange
    local plan_output="/tmp/test-plan.md"
    echo "# Plan" > "$plan_output"

    # Act
    run em-executor execute "$plan_output"

    # Assert
    [ -f ".claude/reports/executor/execution-report.md" ]
    grep -q "Plan executed" ".claude/reports/executor/execution-report.md"
}
```

---

## Running Tests

### Run All Tests

```bash
# Run complete test suite
cd tests
./run-e2e-tests.sh

# Output:
# Running 20 E2E tests...
# ✓ test-core-commands
# ✓ test-agent-invocation
# ✓ test-workflow-execution
# ...
# All tests passed! (20/20)
```

### Run Specific Test Category

```bash
# E2E tests only
cd tests
./run-e2e-tests.sh --e2e

# Unit tests only
cd tests/unit
./run-unit-tests.sh

# Integration tests only
cd tests/integration
./run-integration-tests.sh
```

### Run Individual Test

```bash
# Specific test file
cd tests
./test-tdd-auto-retry.sh

# Specific test function
cd tests
bats --filter "test_tdd_retry_with_exponential_backoff" test-tdd-auto-retry.sh
```

### Run with Verbose Output

```bash
# Verbose mode
cd tests
./run-e2e-tests.sh --verbose

# Output includes:
# - Detailed test output
# - Error messages
# - Stack traces
# - Timing information
```

### Run in CI Mode

```bash
# CI mode (no interactive prompts)
cd tests
./run-e2e-tests.sh --ci-mode

# Features:
# - No user prompts
# - Fail fast on first error
# - Generate JUnit XML
# - Exit with proper code
```

---

## Test Structure

### Directory Structure

```
tests/
├── e2e/                          # End-to-end tests
│   ├── test-core-commands.sh
│   ├── test-agent-invocation.sh
│   ├── test-distributed-orchestrator.sh
│   └── ...
├── unit/                         # Unit tests
│   ├── test-token-counter.sh
│   ├── test-tdd-context-manager.sh
│   └── ...
├── integration/                  # Integration tests
│   ├── test-agent-handoff.sh
│   ├── test-distributed-coordination.sh
│   └── ...
├── fixtures/                     # Test fixtures
│   ├── sample-reports/
│   ├── test-knowledge/
│   └── mock-data/
├── helpers/                      # Test helper functions
│   ├── test-helpers.sh
│   ├── assertions.sh
│   └── mock-functions.sh
├── run-e2e-tests.sh             # Main test runner
├── run-unit-tests.sh            # Unit test runner
└── run-integration-tests.sh     # Integration test runner
```

### Test File Template

```bash
#!/usr/bin/env bash
# test-feature-name.sh

# Load test helpers
source "$(dirname "$0")/helpers/test-helpers.sh"

setup() {
    # Setup before each test
    TEST_DIR=$(mktemp -d -t em-test-XXXXXX)
    export TEST_DIR
}

teardown() {
    # Cleanup after each test
    rm -rf "$TEST_DIR"
}

@test "test_should_do_something_expected" {
    # Arrange
    local input="test-value"

    # Act
    local result=$(function_under_test "$input")

    # Assert
    [ "$result" == "expected-output" ]
}

@test "test_should_handle_error_case" {
    # Arrange
    local invalid_input=""

    # Act
    run function_under_test "$invalid_input"

    # Assert
    [ "$status" -ne 0 ]
    [ "$output" =~ "error" ]
}
```

---

## Coverage

### Coverage Goals

```yaml
overall_coverage:
  target: "80%+"
  critical_paths: "90%+"

by_component:
  core_scripts: "85%+"
  agent_definitions: "100%" (documentation)
  skill_definitions: "100%" (documentation)
  workflows: "100%" (documentation)
  distributed_system: "80%+"
  token_management: "85%+"
  tdd_retry: "90%+"
```

### Generate Coverage Report

```bash
# Generate coverage
cd tests
./run-e2e-tests.sh --coverage

# Output:
# Coverage report:
# Overall: 82.3%
# Core scripts: 86.7%
# Distributed system: 81.2%
# Token management: 88.5%
# TDD retry: 91.3%

# View detailed report
open coverage/index.html
```

### Coverage by File

```bash
# Check specific file coverage
cd tests
./run-e2e-tests.sh --coverage-file scripts/token-counter.sh

# Output:
# scripts/token-counter.sh: 87.5%
#   estimate_tokens(): 100%
#   check_threshold(): 100%
#   compare_to_budget(): 75%
#   format_tokens(): 100%
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: EM-Team Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup dependencies
        run: |
          sudo apt-get install -y tmux bats
          pip install tiktoken

      - name: Run E2E tests
        run: |
          cd tests
          ./run-e2e-tests.sh --ci-mode

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/coverage.xml
```

### GitLab CI

```yaml
# .gitlab-ci.yml
test:
  stage: test
  script:
    - apt-get update && apt-get install -y tmux bats
    - pip install tiktoken
    - cd tests
    - ./run-e2e-tests.sh --ci-mode
  coverage: '/Overall: \d+\.\d+%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura.xml
```

### Pre-commit Hook

```bash
# hooks/pre-commit (existing hook)
# Tests run automatically on commit
# Failing tests block commit

# Manual run
./tests/run-e2e-tests.sh --quick
# Runs fast subset (< 2 minutes)
```

---

## Test Data Management

### Fixtures

```bash
# Sample reports for testing
tests/fixtures/sample-reports/
├── backend-report.md
├── frontend-report.md
├── database-report.md
└── consolidated-report.md

# Test knowledge base
tests/fixtures/test-knowledge/
├── project-conventions.md
├── coding-style.md
└── architecture-patterns.md

# Mock data
tests/fixtures/mock-data/
├── large-report.md (150K+ tokens)
├── small-report.md (10K tokens)
└── error-scenarios.json
```

### Test Environment

```bash
# Temporary directories for tests
/tmp/em-team-test-*
/tmp/claude-work-reports-test/
/tmp/claude-work-logs-test/

# Cleanup after tests
cleanup_test_environment() {
    rm -rf /tmp/em-team-test-*
    rm -rf /tmp/claude-work-reports-test/
}
```

---

## Debugging Tests

### Debug Failed Test

```bash
# Run single test with verbose output
cd tests
bats --verbose --filter "test_failing_function" test-file.sh

# Check test artifacts
ls -la /tmp/em-team-test-*

# View test logs
cat /tmp/em-team-test-logs/latest.log

# Inspect test directory
ls -la /tmp/em-team-test-XXXXXX/
```

### Common Test Failures

```bash
# Issue: tmux session already exists
# Fix: Kill existing sessions
tmux kill-server

# Issue: Test artifacts not cleaned up
# Fix: Manual cleanup
rm -rf /tmp/em-team-test-*

# Issue: tiktoken not installed
# Fix: Install dependency
pip install tiktoken
```

### Test Isolation

```bash
# Run tests in isolated environment
cd tests
./run-e2e-tests.sh --isolate

# Features:
# - Separate temp directories per test
# - No shared state
# - Parallel test execution
```

---

## Writing New Tests

### Test Checklist

```yaml
before_writing:
  - Understand what to test
  - Identify test scenarios
  - Set up test fixtures
  - Define expected outcomes

when_writing:
  - Use descriptive test names
  - Follow Arrange-Act-Assert pattern
  - Test both success and failure cases
  - Clean up resources in teardown

after_writing:
  - Run test locally
  - Verify it passes
  - Check edge cases
  - Add to CI/CD
```

### Test Naming Convention

```bash
# Good: Descriptive
@test "test_tdd_retry_with_exponential_backoff_success_on_third_try"

# Bad: Vague
@test "test_retry"

# Good: Specific
@test "test_token_summarization_preserves_critical_issues_100_percent"

# Bad: Generic
@test "test_summarization"
```

---

## Test Metrics

### Success Metrics

```yaml
test_success_rate:
  target: "100% for E2E"
  target: "95%+ for unit"
  target: "90%+ for integration"

test_duration:
  e2e_tests: "< 10 minutes"
  unit_tests: "< 2 minutes"
  integration_tests: "< 5 minutes"

flakiness:
  target: "0% flaky tests"
  threshold: "3 failures in 10 runs = flaky"
```

### Track Metrics

```bash
# Generate test metrics report
cd tests
./run-e2e-tests.sh --metrics

# Output:
# Test Metrics:
# Success rate: 100% (20/20)
# Duration: 8m 32s
# Flaky tests: 0
# Coverage: 82.3%
```

---

## Related Documentation

- [TDD Auto-Retry](../TDD-AUTO-RETRY.md) - TDD retry mechanism
- [Token Summarization](../TOKEN-SUMMARIZATION.md) - Token management tests
- [Knowledge Persistence](../KNOWLEDGE-PERSISTENCE.md) - Knowledge base tests
- [Distributed System](../architecture/distributed-system.md) - Distributed architecture

---

## Contributing Tests

When adding new features:

1. **Write tests first** (TDD)
2. **Ensure coverage** meets targets
3. **Document tests** clearly
4. **Add to CI/CD**
5. **Update documentation**

---

**Version:** 1.2.0
**Last Updated:** 2026-04-19
**Test Framework:** Bats (Bash Automated Testing System)
