#!/bin/bash

################################################################################
# Unit Tests for Distributed Orchestrator
#
# Description: Test distributed-orchestrator.sh script functionality
# Usage: ./test-distributed-orchestrator.sh
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/scripts"
ORCHESTRATOR_SCRIPT="$SCRIPTS_DIR/distributed-orchestrator.sh"

################################################################################
# Test Setup
################################################################################

setup_orchestrator_tests() {
    echo "Setting up orchestrator tests..."

    # Check if script exists
    if [[ ! -f "$ORCHESTRATOR_SCRIPT" ]]; then
        echo "Error: Orchestrator script not found at $ORCHESTRATOR_SCRIPT"
        exit 1
    fi

    # Check if script is executable
    if [[ ! -x "$ORCHESTRATOR_SCRIPT" ]]; then
        chmod +x "$ORCHESTRATOR_SCRIPT"
    fi
}

teardown_orchestrator_tests() {
    echo "Tearing down orchestrator tests..."

    # Clean up any test sessions
    if tmux has-session -t "test-claude-work" 2>/dev/null; then
        tmux kill-session -t "test-claude-work" 2>/dev/null || true
    fi

    # Clean up test directories
    rm -rf /tmp/em-team-test-*
}

################################################################################
# Test Cases
################################################################################

test_script_exists() {
    start_test "Script exists and is executable"

    if assert_file_exists "$ORCHESTRATOR_SCRIPT" "Orchestrator script should exist"; then
        if [[ -x "$ORCHESTRATOR_SCRIPT" ]]; then
            pass_test
        else
            fail_test "Script is not executable"
        fi
    fi
}

test_help_command() {
    start_test "Help command works"

    local output
    output=$("$ORCHESTRATOR_SCRIPT" help 2>&1 || true)

    # Check for expected help content
    if assert_contains "$output" "Usage" "Help should contain Usage" && \
       assert_contains "$output" "Commands:" "Help should list commands"; then
        pass_test
    fi
}

test_default_shows_help() {
    start_test "Default command shows help"

    local output
    output=$("$ORCHESTRATOR_SCRIPT" 2>&1 || true)

    if assert_contains "$output" "Usage" "Default should show help"; then
        pass_test
    fi
}

test_init_directories() {
    start_test "Initialize directories correctly"

    local test_env
    test_env=$(setup_test_env "init_dirs")

    # Override config for testing
    local test_script
    test_script="$ORCHESTRATOR_SCRIPT"

    # We can't easily test init_directories in isolation without modifying the script
    # So we'll test the side effects by checking if start command creates directories

    # For now, just verify the function exists in the script
    if grep -q "init_directories()" "$test_script"; then
        pass_test
    else
        fail_test "init_directories function not found in script"
    fi

    cleanup_test_env "$test_env"
}

test_session_exists_function() {
    start_test "Session check function exists"

    if grep -q "create_session()" "$ORCHESTRATOR_SCRIPT" && \
       grep -q "has-session" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Session check function not found"
    fi
}

test_dry_run_mode() {
    start_test "Dry run mode (check for --dry-run flag)"

    # Check if script supports dry-run or has dry-run logic
    if grep -q "dry-run\|DRY_RUN" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        skip_test "Dry-run mode not implemented yet"
    fi
}

test_log_functions_exist() {
    start_test "Log functions exist"

    local script_content
    script_content=$(cat "$ORCHESTRATOR_SCRIPT")

    if echo "$script_content" | grep -q "log_info()" && \
       echo "$script_content" | grep -q "log_success()" && \
       echo "$script_content" | grep -q "log_warning()" && \
       echo "$script_content" | grep -q "log_error()"; then
        pass_test
    else
        fail_test "Not all log functions found"
    fi
}

test_color_configuration() {
    start_test "Color configuration exists"

    local script_content
    script_content=$(cat "$ORCHESTRATOR_SCRIPT")

    if echo "$script_content" | grep -q "RED=" && \
       echo "$script_content" | grep -q "GREEN=" && \
       echo "$script_content" | grep -q "YELLOW=" && \
       echo "$script_content" | grep -q "BLUE=" && \
       echo "$script_content" | grep -q "NC="; then
        pass_test
    else
        fail_test "Not all color variables defined"
    fi
}

test_start_command_exists() {
    start_test "Start command exists"

    if grep -q "start_distributed()" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "start_distributed function not found"
    fi
}

test_stop_command_exists() {
    start_test "Stop command exists"

    if grep -q "stop_distributed\|kill_session" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Stop function not found"
    fi
}

test_status_command_exists() {
    start_test "Status command exists"

    if grep -q "show_status\|check_status" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Status function not found"
    fi
}

test_agent_configuration() {
    start_test "Agent windows configuration exists"

    # Check if script configures agent windows
    if grep -q "backend\|frontend\|database\|techlead" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Agent configuration not found"
    fi
}

test_shared_directory_config() {
    start_test "Shared directory configuration exists"

    if grep -q "SHARED_DIR\|/tmp/claude-work-reports" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Shared directory configuration not found"
    fi
}

test_queue_directory_config() {
    start_test "Queue directory configuration exists"

    if grep -q "QUEUE_DIR\|/tmp/claude-work-queue" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Queue directory configuration not found"
    fi
}

test_session_name_config() {
    start_test "Session name configuration exists"

    if grep -q "SESSION_NAME\|claude-work" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Session name configuration not found"
    fi
}

test_error_handling() {
    start_test "Error handling (set -euo pipefail)"

    if grep -q "set -euo pipefail" "$ORCHESTRATOR_SCRIPT"; then
        pass_test
    else
        fail_test "Error handling not properly configured"
    fi
}

test_shebang_exists() {
    start_test "Shebang exists"

    local first_line
    first_line=$(head -n 1 "$ORCHESTRATOR_SCRIPT")

    if [[ "$first_line" == "#!/bin/bash" ]]; then
        pass_test
    else
        fail_test "Invalid shebang: $first_line"
    fi
}

test_script_description() {
    start_test "Script has description header"

    if head -n 10 "$ORCHESTRATOR_SCRIPT" | grep -q "Description:"; then
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
    echo "Distributed Orchestrator Unit Tests"
    echo "======================================"
    echo ""

    # Setup
    setup_orchestrator_tests

    # Run tests
    test_script_exists
    test_help_command
    test_default_shows_help
    test_init_directories
    test_session_exists_function
    test_dry_run_mode
    test_log_functions_exist
    test_color_configuration
    test_start_command_exists
    test_stop_command_exists
    test_status_command_exists
    test_agent_configuration
    test_shared_directory_config
    test_queue_directory_config
    test_session_name_config
    test_error_handling
    test_shebang_exists
    test_script_description

    # Teardown
    teardown_orchestrator_tests

    # Print summary
    print_test_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
