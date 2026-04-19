#!/bin/bash
#
# Test Suite for TDD Auto-Retry Mechanism
# Tests the retry wrapper, context manager, and integration
#

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
CONTEXT_DIR=".claude/tdd-context"
WRAPPER_SCRIPT="$SCRIPT_DIR/tdd-retry-wrapper.sh"
CONTEXT_MANAGER="$SCRIPT_DIR/tdd-context-manager.sh"

################################################################################
# Setup and Cleanup
################################################################################

setup_test() {
    # Clean up any existing context
    if [[ -d "$CONTEXT_DIR" ]]; then
        rm -rf "$CONTEXT_DIR"
    fi

    # Create context directory
    mkdir -p "$CONTEXT_DIR"
}

cleanup_test() {
    # Clean up test artifacts
    if [[ -d "$CONTEXT_DIR" ]]; then
        rm -rf "$CONTEXT_DIR"
    fi
}

################################################################################
# Tests
################################################################################

# Test 1: Successful test execution resets counter
test_success_resets_counter() {
    start_test "Success resets retry counter"

    # Setup: Create retry count
    echo "2" > "$CONTEXT_DIR/test-retry-count.txt"

    # Execute successful test
    if "$WRAPPER_SCRIPT" run "exit 0" 3 >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Successful test should return exit code 0"
    fi

    # Verify counter was reset
    if [[ ! -f "$CONTEXT_DIR/test-retry-count.txt" ]]; then
        echo "    ✓ Counter file removed on success"
    else
        fail_test "Counter should be removed on success"
    fi
}

# Test 2: Failed test creates context
test_failure_creates_context() {
    start_test "Failure creates error context"

    # Setup: Ensure clean state
    rm -f "$CONTEXT_DIR/test-latest-failure.json"

    # Execute failing test
    if "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1; then
        fail_test "Failing test should return non-zero exit code"
    fi

    # Verify context file was created
    if [[ -f "$CONTEXT_DIR/test-latest-failure.json" ]]; then
        # Verify JSON is valid
        if jq empty "$CONTEXT_DIR/test-latest-failure.json" 2>/dev/null; then
            pass_test
        else
            fail_test "Context file should contain valid JSON"
        fi
    else
        fail_test "Context file should be created on failure"
    fi
}

# Test 3: Retry counter increments
test_retry_counter_increments() {
    start_test "Retry counter increments correctly"

    # First failure
    "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1 || true

    local count=$(cat "$CONTEXT_DIR/test-retry-count.txt" 2>/dev/null || echo "0")

    if [[ "$count" == "1" ]]; then
        pass_test
    else
        fail_test "Expected retry count 1, got $count"
    fi
}

# Test 4: Exit code 42 for retry available
test_exit_code_retry_available() {
    start_test "Exit code 42 when retry available"

    # Clean state
    rm -f "$CONTEXT_DIR/test-retry-count.txt"

    # Execute failing test
    "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1
    local exit_code=$?

    if [[ $exit_code -eq 42 ]]; then
        pass_test
    else
        fail_test "Expected exit code 42, got $exit_code"
    fi
}

# Test 5: Exit code 43 for max retries exceeded
test_exit_code_max_retries() {
    start_test "Exit code 43 when max retries exceeded"

    # Set retry count to max
    echo "3" > "$CONTEXT_DIR/test-retry-count.txt"

    # Execute failing test
    "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1
    local exit_code=$?

    if [[ $exit_code -eq 43 ]]; then
        pass_test
    else
        fail_test "Expected exit code 43, got $exit_code"
    fi
}

# Test 6: Context manager format command
test_context_manager_format() {
    start_test "Context manager formats failure"

    # Create a failure
    "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1 || true

    # Format the failure
    local output=$("$CONTEXT_MANAGER" format 2>&1)

    # Check if output contains expected sections
    if echo "$output" | grep -q "TDD Test Failure"; then
        pass_test
    else
        fail_test "Formatted output should contain 'TDD Test Failure'"
    fi
}

# Test 7: Context manager status command
test_context_manager_status() {
    start_test "Context manager shows status"

    # Create a failure
    "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1 || true

    # Get status
    local output=$("$CONTEXT_MANAGER" status 2>&1)

    # Check if output contains retry count
    if echo "$output" | grep -q "Current retry count"; then
        pass_test
    else
        fail_test "Status should show retry count"
    fi
}

# Test 8: Context manager reset command
test_context_manager_reset() {
    start_test "Context manager resets context"

    # Create a failure
    "$WRAPPER_SCRIPT" run "exit 1" 3 >/dev/null 2>&1 || true

    # Reset context
    "$CONTEXT_MANAGER" reset >/dev/null 2>&1

    # Verify files are removed
    if [[ ! -f "$CONTEXT_DIR/test-retry-count.txt" ]] && [[ ! -f "$CONTEXT_DIR/test-latest-failure.json" ]]; then
        pass_test
    else
        fail_test "Reset should remove context files"
    fi
}

# Test 9: Exponential backoff delays
test_exponential_backoff() {
    start_test "Exponential backoff delays"

    # This test verifies the delays array is configured correctly
    local source_output=$(source "$WRAPPER_SCRIPT" && echo "${delays[@]}")

    if [[ "$source_output" == "1 2 4" ]]; then
        pass_test
    else
        fail_test "Expected delays '1 2 4', got '$source_output'"
    fi
}

# Test 10: Max retries configuration
test_max_retries_config() {
    start_test "Max retries configuration"

    # This test verifies MAX_RETRIES is set to 3
    local source_output=$(source "$WRAPPER_SCRIPT" && echo "$MAX_RETRIES")

    if [[ "$source_output" == "3" ]]; then
        pass_test
    else
        fail_test "Expected MAX_RETRIES 3, got $source_output"
    fi
}

################################################################################
# Test Execution
################################################################################

main() {
    echo "=========================================="
    echo "TDD Auto-Retry Mechanism Test Suite"
    echo "=========================================="
    echo ""

    # Run all tests
    setup_test

    test_success_resets_counter
    cleanup_test
    setup_test

    test_failure_creates_context
    cleanup_test
    setup_test

    test_retry_counter_increments
    cleanup_test
    setup_test

    test_exit_code_retry_available
    cleanup_test
    setup_test

    test_exit_code_max_retries
    cleanup_test
    setup_test

    test_context_manager_format
    cleanup_test
    setup_test

    test_context_manager_status
    cleanup_test
    setup_test

    test_context_manager_reset
    cleanup_test
    setup_test

    test_exponential_backoff
    cleanup_test
    setup_test

    test_max_retries_config
    cleanup_test

    # Print summary
    print_test_summary
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
