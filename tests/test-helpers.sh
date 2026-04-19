#!/bin/bash

################################################################################
# Test Helper Functions for EM-Team Distributed Orchestration Tests
#
# Description: Shared test utilities and assertions
# Source this file in test scripts: source ./test-helpers.sh
################################################################################

# Test statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
CURRENT_TEST=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# Test Management Functions
################################################################################

start_test() {
    CURRENT_TEST=$1
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "\n${CYAN}[TEST $TESTS_RUN]${NC} $CURRENT_TEST"
}

pass_test() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}[PASS]${NC} $CURRENT_TEST"
    CURRENT_TEST=""
}

fail_test() {
    local reason=$1
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}[FAIL]${NC} $CURRENT_TEST"
    echo -e "       ${RED}Reason: $reason${NC}"
    CURRENT_TEST=""
}

skip_test() {
    local reason=$1
    echo -e "${YELLOW}[SKIP]${NC} $CURRENT_TEST"
    echo -e "        Reason: $reason"
    CURRENT_TEST=""
}

print_test_summary() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Test Summary${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo -e "Total Tests: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "${YELLOW}Skipped: $((TESTS_RUN - TESTS_PASSED - TESTS_FAILED))${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}Some tests failed!${NC}"
        return 1
    fi
}

################################################################################
# Environment Setup/Cleanup
################################################################################

# Set up test environment
setup_test_env() {
    local test_name=$1

    # Create test-specific directories
    export TEST_BASE_DIR="/tmp/em-team-test-$test_name-$$"
    export TEST_SHARED_DIR="$TEST_BASE_DIR/shared"
    export TEST_QUEUE_DIR="$TEST_BASE_DIR/queue"
    export TEST_LOG_DIR="$TEST_BASE_DIR/logs"
    export TEST_SYNC_DIR="$TEST_BASE_DIR/sync"

    mkdir -p "$TEST_SHARED_DIR"/{backend,frontend,database,techlead}
    mkdir -p "$TEST_QUEUE_DIR"
    mkdir -p "$TEST_LOG_DIR"
    mkdir -p "$TEST_SYNC_DIR"

    echo "$TEST_BASE_DIR"
}

# Clean up test environment
cleanup_test_env() {
    local test_base_dir=$1

    if [[ -z "$test_base_dir" ]]; then
        echo "Error: No test base directory provided"
        return 1
    fi

    # Kill any test tmux sessions
    if tmux has-session -t "test-claude-work" 2>/dev/null; then
        tmux kill-session -t "test-claude-work" 2>/dev/null || true
    fi

    # Remove test directories
    if [[ -d "$test_base_dir" ]]; then
        rm -rf "$test_base_dir"
    fi

    echo "Test environment cleaned up: $test_base_dir"
}

################################################################################
# Assertion Functions
################################################################################

# Assert two values are equal
assert_equals() {
    local expected=$1
    local actual=$2
    local message=${3:-"Values should be equal"}

    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        fail_test "$message (expected: '$expected', got: '$actual')"
        return 1
    fi
}

# Assert command succeeds
assert_succeeds() {
    local command=$1
    local message=${2:-"Command should succeed"}

    if eval "$command" >/dev/null 2>&1; then
        return 0
    else
        fail_test "$message (command: $command)"
        return 1
    fi
}

# Assert command fails
assert_fails() {
    local command=$1
    local message=${2:-"Command should fail"}

    if eval "$command" >/dev/null 2>&1; then
        fail_test "$message (command: $command)"
        return 1
    else
        return 0
    fi
}

# Assert file exists
assert_file_exists() {
    local file=$1
    local message=${2:-"File should exist"}

    if [[ -f "$file" ]]; then
        return 0
    else
        fail_test "$message (file: $file)"
        return 1
    fi
}

# Assert file does not exist
assert_file_not_exists() {
    local file=$1
    local message=${2:-"File should not exist"}

    if [[ ! -f "$file" ]]; then
        return 0
    else
        fail_test "$message (file: $file)"
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir=$1
    local message=${2:-"Directory should exist"}

    if [[ -d "$dir" ]]; then
        return 0
    else
        fail_test "$message (directory: $dir)"
        return 1
    fi
}

# Assert string contains substring
assert_contains() {
    local haystack=$1
    local needle=$2
    local message=${3:-"String should contain substring"}

    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        fail_test "$message (expected '$needle' in '$haystack')"
        return 1
    fi
}

# Assert string does not contain substring
assert_not_contains() {
    local haystack=$1
    local needle=$2
    local message=${3:-"String should not contain substring"}

    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    else
        fail_test "$message (did not expect '$needle' in '$haystack')"
        return 1
    fi
}

# Assert exit code equals expected value
assert_exit_code() {
    local expected=$1
    local actual=$2
    local message=${3:-"Exit code should match"}

    if [[ "$expected" -eq "$actual" ]]; then
        return 0
    else
        fail_test "$message (expected: $expected, got: $actual)"
        return 1
    fi
}

# Assert count matches expected value
assert_count() {
    local expected=$1
    local actual=$2
    local message=${3:-"Count should match"}

    if [[ "$expected" -eq "$actual" ]]; then
        return 0
    else
        fail_test "$message (expected: $expected, got: $actual)"
        return 1
    fi
}

################################################################################
# Mock Session Functions
################################################################################

# Create a mock tmux session for testing
create_mock_session() {
    local session_name=${1:-"test-claude-work"}

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Warning: Session '$session_name' already exists"
        return 1
    fi

    tmux new-session -d -s "$session_name"

    # Create mock windows
    tmux new-window -t "$session_name" -n "orchestrator"
    tmux new-window -t "$session_name" -n "backend"
    tmux new-window -t "$session_name" -n "frontend"
    tmux new-window -t "$session_name" -n "database"

    echo "Created mock session: $session_name"
    return 0
}

# Kill a mock tmux session
kill_mock_session() {
    local session_name=${1:-"test-claude-work"}

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux kill-session -t "$session_name"
        echo "Killed mock session: $session_name"
        return 0
    else
        echo "Warning: Session '$session_name' does not exist"
        return 1
    fi
}

################################################################################
# Test Data Generators
################################################################################

# Create a sample task assignment YAML
create_sample_task_assignment() {
    local output_file=$1

    cat > "$output_file" << 'EOF'
---
message_type: task_assignment
message_id: msg-001
timestamp: 2026-04-19T12:00:00Z
from: techlead-orchestrator
to: backend-expert
task:
  task_id: task-001
  title: "Implement user authentication"
  description: "Add JWT-based authentication to the API"
  priority: high
  context:
    feature_branch: feature/auth
    base_branch: main
  deliverables:
    - type: code
      format: md
      description: "Authentication implementation summary"
    - type: test
      format: md
      description: "Test results"
    - type: review
      format: md
      description: "Security review"
deadline: 2026-04-19T14:00:00Z
dependencies: []
status: pending
EOF

    echo "Created sample task assignment: $output_file"
}

# Create a sample status update YAML
create_sample_status_update() {
    local output_file=$1

    cat > "$output_file" << 'EOF'
---
message_type: status_update
message_id: msg-002
timestamp: 2026-04-19T12:30:00Z
from: backend-expert
to: techlead-orchestrator
task_id: task-001
status: in_progress
progress: 50
findings:
  - type: observation
    severity: info
    message: "JWT library selected and installed"
  - type: issue
    severity: warning
    message: "Need to add refresh token rotation"
blockers:
  - "Waiting on database schema approval"
next_steps:
  - "Implement refresh token rotation"
  - "Write unit tests for auth middleware"
EOF

    echo "Created sample status update: $output_file"
}

# Create a sample agent report
create_sample_report() {
    local output_file=$1
    local agent_name=${2:-"backend-expert"}
    local task_id=${3:-"task-001"}

    cat > "$output_file" << EOF
---
report_id: report-001
generated: 2026-04-19T13:00:00Z
agent: $agent_name
task_id: $task_id
status: completed
overall: pass
findings:
  - category: Implementation
    severity: success
    summary: "JWT authentication implemented successfully"
    details: |
      - Created JWT service with HS256 algorithm
      - Added authentication middleware
      - Implemented token refresh mechanism
    evidence:
      - "backend/src/services/jwt.service.ts"
      - "backend/src/middleware/auth.middleware.ts"
  - category: Security
    severity: warning
    summary: "Refresh token rotation needs testing"
    details: |
      Token rotation is implemented but needs comprehensive testing
      to ensure edge cases are handled properly.
    evidence:
      - "backend/src/services/refresh-token.service.ts"
recommendations:
  - priority: high
    action: "Add comprehensive tests for token rotation"
    effort: 2h
  - priority: medium
    action: "Consider implementing token blacklist on logout"
    effort: 4h
next_steps:
  - "Write unit tests for token rotation"
  - "Add integration tests for authentication flow"
  - "Document token management in API docs"
EOF

    echo "Created sample report: $output_file"
}

# Create multiple sample reports for consolidation test
create_consolidation_test_data() {
    local base_dir=$1

    # Create individual agent reports
    create_sample_report "$base_dir/backend/report.md" "backend-expert" "task-001"
    create_sample_report "$base_dir/frontend/report.md" "frontend-expert" "task-002"
    create_sample_report "$base_dir/database/report.md" "database-expert" "task-003"

    echo "Created consolidation test data in: $base_dir"
}

################################################################################
# Utility Functions
################################################################################

# Get script path (works when sourced)
get_script_path() {
    echo "${BASH_SOURCE[0]}"
}

# Get project root directory
get_project_root() {
    local script_dir
    script_dir=$(dirname "$(get_script_path)")
    echo "$(cd "$script_dir/.." && pwd)"
}

# Check if tmux is available
check_tmux() {
    command -v tmux &> /dev/null
}

# Count files in directory
count_files() {
    local dir=$1
    local pattern=${2:-"*"}

    find "$dir" -name "$pattern" -type f | wc -l | tr -d ' '
}

# Get file count by extension
count_files_by_ext() {
    local dir=$1
    local ext=$2

    find "$dir" -name "*.$ext" -type f | wc -l | tr -d ' '
}

################################################################################
# TDD Auto-Retry Support Functions
################################################################################

# Run test with TDD auto-retry wrapper
run_test_with_retry() {
    local test_command=$1
    local max_retries=${2:-3}

    if [[ -f "./tests/tdd-retry-wrapper.sh" ]]; then
        source "./tests/tdd-retry-wrapper.sh"
        run_tdd_with_retry "$test_command" "$max_retries"
    else
        echo "Warning: TDD wrapper not found, running directly"
        eval "$test_command"
    fi
}

# Check if TDD retry context exists
has_retry_context() {
    [[ -f ".claude/tdd-context/test-latest-failure.json" ]]
}

# Get current retry count
get_retry_count() {
    local count_file=".claude/tdd-context/test-retry-count.txt"
    if [[ -f "$count_file" ]]; then
        cat "$count_file"
    else
        echo "0"
    fi
}

# Format TDD failure for display
format_tdd_failure() {
    local failure_file=${1:-".claude/tdd-context/test-latest-failure.json"}

    if [[ -f "./tests/tdd-context-manager.sh" ]]; then
        ./tests/tdd-context-manager.sh format "$failure_file"
    else
        echo "Error: TDD context manager not found"
        return 1
    fi
}

# Log TDD phase transition
log_tdd_phase() {
    local phase=$1
    local message=${2:-""}

    case "$phase" in
        RED)
            echo -e "${RED}🔴 TDD RED PHASE${NC} - Test failing (expected)"
            ;;
        GREEN)
            echo -e "${GREEN}🟢 TDD GREEN PHASE${NC} - Test passing"
            ;;
        REFACTOR)
            echo -e "${YELLOW}🟡 TDD REFACTOR PHASE${NC} - Improving code"
            ;;
        *)
            echo "Unknown TDD phase: $phase"
            return 1
            ;;
    esac

    if [[ -n "$message" ]]; then
        echo "   $message"
    fi
}

# Reset TDD retry context
reset_tdd_context() {
    if [[ -f "./tests/tdd-context-manager.sh" ]]; then
        ./tests/tdd-context-manager.sh reset
    else
        echo "Warning: TDD context manager not found"
        return 1
    fi
}

# Show TDD retry status
show_tdd_status() {
    if [[ -f "./tests/tdd-context-manager.sh" ]]; then
        ./tests/tdd-context-manager.sh status
    else
        echo "Warning: TDD context manager not found"
        return 1
    fi
}

# Export TDD functions
export -f run_test_with_retry has_retry_context get_retry_count
export -f format_tdd_failure log_tdd_phase reset_tdd_context show_tdd_status

################################################################################
# Utility Functions
################################################################################

# Get script path (works when sourced)
get_script_path() {
    echo "${BASH_SOURCE[0]}"
}

# Get project root directory
get_project_root() {
    local script_dir
    script_dir=$(dirname "$(get_script_path)")
    echo "$(cd "$script_dir/.." && pwd)"
}

# Check if tmux is available
check_tmux() {
    command -v tmux &> /dev/null
}

# Count files in directory
count_files() {
    local dir=$1
    local pattern=${2:-"*"}

    find "$dir" -name "$pattern" -type f | wc -l | tr -d ' '
}

# Get file count by extension
count_files_by_ext() {
    local dir=$1
    local ext=$2

    find "$dir" -name "*.$ext" -type f | wc -l | tr -d ' '
}

# Export functions for use in test scripts
export -f start_test pass_test fail_test skip_test print_test_summary
export -f setup_test_env cleanup_test_env
export -f assert_equals assert_succeeds assert_fails
export -f assert_file_exists assert_file_not_exists assert_dir_exists
export -f assert_contains assert_not_contains assert_exit_code assert_count
export -f create_mock_session kill_mock_session
export -f create_sample_task_assignment create_sample_status_update create_sample_report create_consolidation_test_data
export -f get_script_path get_project_root check_tmux count_files count_files_by_ext
