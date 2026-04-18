#!/bin/bash

################################################################################
# Unit Tests for Session Coordinator
#
# Description: Test session-coordinator.sh script functionality
# Usage: ./test-session-coordinator.sh
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
DISTRIBUTED_DIR="$(dirname "$SCRIPT_DIR")/distributed"
COORDINATOR_SCRIPT="$DISTRIBUTED_DIR/session-coordinator.sh"

################################################################################
# Test Setup
################################################################################

setup_coordinator_tests() {
    echo "Setting up session coordinator tests..."

    # Check if script exists
    if [[ ! -f "$COORDINATOR_SCRIPT" ]]; then
        echo "Error: Session coordinator script not found at $COORDINATOR_SCRIPT"
        exit 1
    fi

    # Check if script is executable
    if [[ ! -x "$COORDINATOR_SCRIPT" ]]; then
        chmod +x "$COORDINATOR_SCRIPT"
    fi
}

teardown_coordinator_tests() {
    echo "Tearing down session coordinator tests..."

    # Clean up any test sessions
    if tmux has-session -t "test-claude-work" 2>/dev/null; then
        tmux kill-session -t "test-claude-work" 2>/dev/null || true
    fi

    # Clean up test directories
    rm -rf /tmp/em-skill-test-coordinator-*
}

################################################################################
# Test Cases
################################################################################

test_script_exists() {
    start_test "Script exists and is executable"

    if assert_file_exists "$COORDINATOR_SCRIPT" "Coordinator script should exist"; then
        if [[ -x "$COORDINATOR_SCRIPT" ]]; then
            pass_test
        else
            fail_test "Script is not executable"
        fi
    fi
}

test_help_command() {
    start_test "Help command works"

    local output
    output=$("$COORDINATOR_SCRIPT" help 2>&1 || true)

    if assert_contains "$output" "Usage" "Help should contain Usage" && \
       assert_contains "$output" "Commands:" "Help should list commands"; then
        pass_test
    fi
}

test_check_prerequisites_function() {
    start_test "Check prerequisites function exists"

    if grep -q "check_prerequisites()" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "check_prerequisites function not found"
    fi
}

test_check_prerequisites_tmux() {
    start_test "Check prerequisites checks for tmux"

    if grep -q "command -v tmux\|which tmux" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "tmux check not found"
    fi
}

test_check_prerequisites_session() {
    start_test "Check prerequisites checks for session"

    if grep -q "has-session\|check.*session" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Session check not found"
    fi
}

test_show_topology_function() {
    start_test "Show topology function exists"

    if grep -q "show_topology\|display_topology" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "show_topology function not found"
    fi
}

test_agent_status_function() {
    start_test "Agent status function exists"

    if grep -q "agent_status\|check_agent" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "agent_status function not found"
    fi
}

test_queue_status_function() {
    start_test "Queue status function exists"

    if grep -q "queue_status\|check_queue" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "queue_status function not found"
    fi
}

test_sync_function() {
    start_test "Sync function exists"

    if grep -q "sync_context\|sync_session" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "sync function not found"
    fi
}

test_coordination_function() {
    start_test "Coordination function exists"

    if grep -q "coordinate\|orchestrate" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        skip_test "Coordination function not found"
    fi
}

test_log_functions() {
    start_test "Log functions exist"

    local script_content
    script_content=$(cat "$COORDINATOR_SCRIPT")

    if echo "$script_content" | grep -q "log_info()" && \
       echo "$script_content" | grep -q "log_success()" && \
       echo "$script_content" | grep -q "log_warning()" && \
       echo "$script_content" | grep -q "log_error()"; then
        pass_test
    else
        fail_test "Not all log functions found"
    fi
}

test_debug_log_function() {
    start_test "Debug log function exists"

    if grep -q "log_debug()" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        skip_test "Debug log function not found"
    fi
}

test_color_config() {
    start_test "Color configuration exists"

    local script_content
    script_content=$(cat "$COORDINATOR_SCRIPT")

    if echo "$script_content" | grep -q "RED=" && \
       echo "$script_content" | grep -q "GREEN=" && \
       echo "$script_content" | grep -q "YELLOW=" && \
       echo "$script_content" | grep -q "BLUE=" && \
       echo "$script_content" | grep -q "CYAN="; then
        pass_test
    else
        fail_test "Not all color variables defined"
    fi
}

test_sync_directory_config() {
    start_test "Sync directory configuration exists"

    if grep -q "SYNC_DIR\|sync.*dir" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Sync directory configuration not found"
    fi
}

test_session_config() {
    start_test "Session configuration exists"

    if grep -q "SESSION_NAME" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Session name configuration not found"
    fi
}

test_shared_directory_config() {
    start_test "Shared directory configuration exists"

    if grep -q "SHARED_DIR" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Shared directory configuration not found"
    fi
}

test_queue_directory_config() {
    start_test "Queue directory configuration exists"

    if grep -q "QUEUE_DIR" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Queue directory configuration not found"
    fi
}

test_agent_configuration() {
    start_test "Agent configuration exists"

    if grep -q "backend\|frontend\|database\|techlead" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Agent configuration not found"
    fi
}

test_error_handling() {
    start_test "Error handling (set -euo pipefail)"

    if grep -q "set -euo pipefail" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Error handling not properly configured"
    fi
}

test_tmux_integration() {
    start_test "tmux integration exists"

    if grep -q "tmux" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        fail_test "tmux integration not found"
    fi
}

test_window_operations() {
    start_test "Window operations exist"

    if grep -q "list-windows\|new-window\|select-window" "$COORDINATOR_SCRIPT"; then
        pass_test
    else
        skip_test "Window operations not fully implemented"
    fi
}

test_shebang() {
    start_test "Correct shebang"

    local first_line
    first_line=$(head -n 1 "$COORDINATOR_SCRIPT")

    if [[ "$first_line" == "#!/bin/bash" ]]; then
        pass_test
    else
        fail_test "Invalid shebang: $first_line"
    fi
}

test_description_header() {
    start_test "Script has description header"

    if head -n 10 "$COORDINATOR_SCRIPT" | grep -q "Description:"; then
        pass_test
    else
        fail_test "Script description not found"
    fi
}

################################################################################
# Test Runner
################################################################################

run_all_tests() {
    echo "======================================"
    echo "Session Coordinator Unit Tests"
    echo "======================================"
    echo ""

    # Setup
    setup_coordinator_tests

    # Run tests
    test_script_exists
    test_help_command
    test_check_prerequisites_function
    test_check_prerequisites_tmux
    test_check_prerequisites_session
    test_show_topology_function
    test_agent_status_function
    test_queue_status_function
    test_sync_function
    test_coordination_function
    test_log_functions
    test_debug_log_function
    test_color_config
    test_sync_directory_config
    test_session_config
    test_shared_directory_config
    test_queue_directory_config
    test_agent_configuration
    test_error_handling
    test_tmux_integration
    test_window_operations
    test_shebang
    test_description_header

    # Teardown
    teardown_coordinator_tests

    # Print summary
    print_test_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
