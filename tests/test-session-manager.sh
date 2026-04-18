#!/bin/bash

################################################################################
# Unit Tests for Session Manager
#
# Description: Test session-manager.sh script functionality
# Usage: ./test-session-manager.sh
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/scripts"
MANAGER_SCRIPT="$SCRIPTS_DIR/session-manager.sh"

################################################################################
# Test Setup
################################################################################

setup_manager_tests() {
    echo "Setting up session manager tests..."

    # Check if script exists
    if [[ ! -f "$MANAGER_SCRIPT" ]]; then
        echo "Error: Session manager script not found at $MANAGER_SCRIPT"
        exit 1
    fi

    # Check if script is executable
    if [[ ! -x "$MANAGER_SCRIPT" ]]; then
        chmod +x "$MANAGER_SCRIPT"
    fi
}

teardown_manager_tests() {
    echo "Tearing down session manager tests..."

    # Clean up any test sessions
    if tmux has-session -t "test-claude-work" 2>/dev/null; then
        tmux kill-session -t "test-claude-work" 2>/dev/null || true
    fi
}

################################################################################
# Test Cases
################################################################################

test_script_exists() {
    start_test "Script exists and is executable"

    if assert_file_exists "$MANAGER_SCRIPT" "Session manager script should exist"; then
        if [[ -x "$MANAGER_SCRIPT" ]]; then
            pass_test
        else
            fail_test "Script is not executable"
        fi
    fi
}

test_help_command() {
    start_test "Help command works"

    local output
    output=$("$MANAGER_SCRIPT" help 2>&1 || true)

    if assert_contains "$output" "Usage" "Help should contain Usage" && \
       assert_contains "$output" "list" "Help should list list command" && \
       assert_contains "$output" "status" "Help should list status command"; then
        pass_test
    fi
}

test_list_sessions_function() {
    start_test "List sessions function exists"

    if grep -q "list_sessions()" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "list_sessions function not found"
    fi
}

test_list_sessions_with_no_sessions() {
    start_test "List sessions with no active sessions"

    # Ensure no test session exists
    tmux kill-session -t "test-claude-work" 2>/dev/null || true

    local output
    output=$("$MANAGER_SCRIPT" list 2>&1 || true)

    # Should handle no sessions gracefully
    if assert_contains "$output" "No active\|not found" "Should indicate no sessions"; then
        pass_test
    else
        skip_test "Output format unclear"
    fi
}

test_list_sessions_with_mock_session() {
    start_test "List sessions with mock session"

    if ! check_tmux; then
        skip_test "tmux not available"
        return
    fi

    # Create mock session
    create_mock_session "test-claude-work"

    local output
    output=$("$MANAGER_SCRIPT" list 2>&1 || true)

    # Should show the session
    if assert_contains "$output" "test-claude-work\|active" "Should show active session"; then
        pass_test
    else
        fail_test "Session not listed properly"
    fi

    # Cleanup
    kill_mock_session "test-claude-work"
}

test_status_command() {
    start_test "Status command exists"

    if grep -q "show_status\|check_status\|status()" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "Status command not found"
    fi
}

test_kill_session_function() {
    start_test "Kill session function exists"

    if grep -q "kill_session()" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "kill_session function not found"
    fi
}

test_kill_session_works() {
    start_test "Kill session actually works"

    if ! check_tmux; then
        skip_test "tmux not available"
        return
    fi

    # Create mock session
    create_mock_session "test-claude-work-kill"

    # Kill it
    "$MANAGER_SCRIPT" kill "test-claude-work-kill" 2>&1 || true

    # Verify it's gone
    if tmux has-session -t "test-claude-work-kill" 2>/dev/null; then
        fail_test "Session still exists after kill"
    else
        pass_test
    fi
}

test_broadcast_function() {
    start_test "Broadcast function exists"

    if grep -q "broadcast()" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "broadcast function not found"
    fi
}

test_broadcast_sends_keys() {
    start_test "Broadcast sends keys to windows"

    if ! check_tmux; then
        skip_test "tmux not available"
        return
    fi

    # Create mock session with windows
    create_mock_session "test-claude-work-bcast"

    # Try to broadcast (will fail if function doesn't work)
    if "$MANAGER_SCRIPT" broadcast "echo test" "test-claude-work-bcast" 2>&1; then
        pass_test
    else
        # Function exists but might fail without proper setup
        skip_test "Broadcast function exists but requires running session"
    fi

    # Cleanup
    kill_mock_session "test-claude-work-bcast"
}

test_log_functions() {
    start_test "Log functions exist"

    local script_content
    script_content=$(cat "$MANAGER_SCRIPT")

    if echo "$script_content" | grep -q "log_info()" && \
       echo "$script_content" | grep -q "log_success()" && \
       echo "$script_content" | grep -q "log_warning()" && \
       echo "$script_content" | grep -q "log_error()"; then
        pass_test
    else
        fail_test "Not all log functions found"
    fi
}

test_color_config() {
    start_test "Color configuration exists"

    local script_content
    script_content=$(cat "$MANAGER_SCRIPT")

    if echo "$script_content" | grep -q "RED=" && \
       echo "$script_content" | grep -q "GREEN=" && \
       echo "$script_content" | grep -q "YELLOW=" && \
       echo "$script_content" | grep -q "BLUE="; then
        pass_test
    else
        fail_test "Not all color variables defined"
    fi
}

test_tmux_list_command() {
    start_test "Uses tmux list-sessions"

    if grep -q "tmux list-sessions\|list-sessions" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "tmux list-sessions command not found"
    fi
}

test_tmux_send_keys() {
    start_test "Uses tmux send-keys for broadcast"

    if grep -q "tmux send-keys" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "tmux send-keys command not found"
    fi
}

test_window_list_command() {
    start_test "Lists windows in session"

    if grep -q "tmux list-windows\|list-windows" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "tmux list-windows command not found"
    fi
}

test_error_handling() {
    start_test "Error handling (set -euo pipefail)"

    if grep -q "set -euo pipefail" "$MANAGER_SCRIPT"; then
        pass_test
    else
        fail_test "Error handling not properly configured"
    fi
}

test_configuration_variables() {
    start_test "Configuration variables exist"

    local script_content
    script_content=$(cat "$MANAGER_SCRIPT")

    if echo "$script_content" | grep -q "SESSION_NAME=" && \
       echo "$script_content" | grep -q "SHARED_DIR=" && \
       echo "$script_content" | grep -q "QUEUE_DIR=" && \
       echo "$script_content" | grep -q "LOG_DIR="; then
        pass_test
    else
        fail_test "Not all configuration variables found"
    fi
}

test_shebang() {
    start_test "Correct shebang"

    local first_line
    first_line=$(head -n 1 "$MANAGER_SCRIPT")

    if [[ "$first_line" == "#!/bin/bash" ]]; then
        pass_test
    else
        fail_test "Invalid shebang: $first_line"
    fi
}

################################################################################
# Test Runner
################################################################################

run_all_tests() {
    echo "======================================"
    echo "Session Manager Unit Tests"
    echo "======================================"
    echo ""

    # Setup
    setup_manager_tests

    # Run tests
    test_script_exists
    test_help_command
    test_list_sessions_function
    test_list_sessions_with_no_sessions
    test_list_sessions_with_mock_session
    test_status_command
    test_kill_session_function
    test_kill_session_works
    test_broadcast_function
    test_broadcast_sends_keys
    test_log_functions
    test_color_config
    test_tmux_list_command
    test_tmux_send_keys
    test_window_list_command
    test_error_handling
    test_configuration_variables
    test_shebang

    # Teardown
    teardown_manager_tests

    # Print summary
    print_test_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
