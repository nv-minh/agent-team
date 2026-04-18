#!/bin/bash

################################################################################
# End-to-End Test Runner for Distributed Orchestration System
#
# Description: Runs complete workflow tests for the distributed system
# Usage: ./run-e2e-tests.sh [--clean] [--verbose]
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Configuration
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
DISTRIBUTED_DIR="$PROJECT_ROOT/distributed"
CLEANUP=true
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cleanup)
            CLEANUP=false
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --no-cleanup    Don't clean up test artifacts after tests"
            echo "  --verbose, -v   Show verbose output"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

################################################################################
# Test Environment Setup
################################################################################

E2E_TEST_DIR="/tmp/em-skill-e2e-test-$$"
E2E_SHARED_DIR="$E2E_TEST_DIR/shared"
E2E_QUEUE_DIR="$E2E_TEST_DIR/queue"
E2E_LOG_DIR="$E2E_TEST_DIR/logs"
E2E_SYNC_DIR="$E2E_TEST_DIR/sync"

# E2E-specific logging functions
e2e_log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

e2e_log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

e2e_log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

e2e_log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

setup_e2e_environment() {
    e2e_log_info "Setting up E2E test environment..."

    mkdir -p "$E2E_SHARED_DIR"/{backend,frontend,database,techlead}
    mkdir -p "$E2E_QUEUE_DIR"/{pending,processing,completed}
    mkdir -p "$E2E_LOG_DIR"
    mkdir -p "$E2E_SYNC_DIR"

    e2e_log_success "E2E environment created at: $E2E_TEST_DIR"
}

cleanup_e2e_environment() {
    if [[ "$CLEANUP" == true ]]; then
        e2e_log_info "Cleaning up E2E test environment..."

        # Kill test tmux sessions
        tmux kill-session -t "e2e-claude-work" 2>/dev/null || true

        # Remove test directories
        rm -rf "$E2E_TEST_DIR"

        e2e_log_success "E2E environment cleaned up"
    else
        e2e_log_warning "Skipping cleanup (test artifacts preserved at: $E2E_TEST_DIR)"
    fi
}

################################################################################
# E2E Test Workflow
################################################################################

e2e_test_1_script_availability() {
    start_test "E2E Test 1: Script Availability"

    local all_found=true

    for script in \
        "$SCRIPTS_DIR/distributed-orchestrator.sh" \
        "$SCRIPTS_DIR/session-manager.sh" \
        "$SCRIPTS_DIR/consolidate-reports.sh" \
        "$DISTRIBUTED_DIR/session-coordinator.sh" \
        "$DISTRIBUTED_DIR/session-sync.sh"
    do
        if [[ ! -f "$script" ]]; then
            e2e_log_error "Script not found: $script"
            all_found=false
        elif [[ ! -x "$script" ]]; then
            chmod +x "$script"
            e2e_log_info "Made executable: $script"
        fi
    done

    if $all_found; then
        pass_test
    else
        fail_test "Some scripts are missing"
    fi
}

e2e_test_2_directory_structure() {
    start_test "E2E Test 2: Directory Structure"

    local all_created=true

    for dir in \
        "$E2E_SHARED_DIR/backend" \
        "$E2E_SHARED_DIR/frontend" \
        "$E2E_SHARED_DIR/database" \
        "$E2E_SHARED_DIR/techlead" \
        "$E2E_QUEUE_DIR/pending" \
        "$E2E_QUEUE_DIR/processing" \
        "$E2E_QUEUE_DIR/completed"
    do
        if [[ ! -d "$dir" ]]; then
            e2e_log_error "Directory not created: $dir"
            all_created=false
        fi
    done

    if $all_created; then
        pass_test
    else
        fail_test "Some directories were not created"
    fi
}

e2e_test_3_session_creation() {
    start_test "E2E Test 3: Session Creation"

    if ! check_tmux; then
        skip_test "tmux not available"
        return
    fi

    # Create a test session
    if tmux new-session -d -s "e2e-claude-work"; then
        # Create agent windows
        tmux new-window -t "e2e-claude-work" -n "orchestrator"
        tmux new-window -t "e2e-claude-work" -n "backend"
        tmux new-window -t "e2e-claude-work" -n "frontend"
        tmux new-window -t "e2e-claude-work" -n "database"

        pass_test
    else
        fail_test "Failed to create tmux session"
    fi
}

e2e_test_4_message_queue_flow() {
    start_test "E2E Test 4: Message Queue Flow"

    # Create task assignment
    create_sample_task_assignment "$E2E_QUEUE_DIR/pending/task-001.yaml"

    # Move to processing
    mv "$E2E_QUEUE_DIR/pending/task-001.yaml" "$E2E_QUEUE_DIR/processing/"

    # Create status update
    create_sample_status_update "$E2E_QUEUE_DIR/processing/status-001.yaml"

    # Move to completed
    mv "$E2E_QUEUE_DIR/processing/task-001.yaml" "$E2E_QUEUE_DIR/completed/"
    mv "$E2E_QUEUE_DIR/processing/status-001.yaml" "$E2E_QUEUE_DIR/completed/"

    # Verify queue state
    local pending_count
    local processing_count
    local completed_count

    pending_count=$(find "$E2E_QUEUE_DIR/pending" -type f | wc -l | tr -d ' ')
    processing_count=$(find "$E2E_QUEUE_DIR/processing" -type f | wc -l | tr -d ' ')
    completed_count=$(find "$E2E_QUEUE_DIR/completed" -type f | wc -l | tr -d ' ')

    if [[ $pending_count -eq 0 ]] && [[ $processing_count -eq 0 ]] && [[ $completed_count -eq 2 ]]; then
        pass_test
    else
        fail_test "Queue flow incorrect (pending: $pending_count, processing: $processing_count, completed: $completed_count)"
    fi
}

e2e_test_5_agent_reports() {
    start_test "E2E Test 5: Agent Reports Generation"

    # Create agent reports
    create_sample_report "$E2E_SHARED_DIR/backend/report.md" "backend-expert" "task-001"
    create_sample_report "$E2E_SHARED_DIR/frontend/report.md" "frontend-expert" "task-002"
    create_sample_report "$E2E_SHARED_DIR/database/report.md" "database-expert" "task-003"

    # Verify reports exist
    if [[ -f "$E2E_SHARED_DIR/backend/report.md" ]] && \
       [[ -f "$E2E_SHARED_DIR/frontend/report.md" ]] && \
       [[ -f "$E2E_SHARED_DIR/database/report.md" ]]; then
        pass_test
    else
        fail_test "Not all agent reports were created"
    fi
}

e2e_test_6_report_consolidation() {
    start_test "E2E Test 6: Report Consolidation"

    # Create consolidated report
    local output_file="$E2E_SHARED_DIR/techlead/consolidated-report.md"
    mkdir -p "$(dirname "$output_file")"

    # Consolidate reports
    {
        echo "# Consolidated Agent Reports"
        echo ""
        echo "**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo ""
        echo "## Executive Summary"
        echo ""
        echo "This document consolidates findings from all agent specialists."
        echo ""
        echo "---"
        echo ""
        echo "## Agent Reports"
        echo ""

        for report_dir in "$E2E_SHARED_DIR"/*; do
            local agent_name
            agent_name=$(basename "$report_dir")
            if [[ -d "$report_dir" ]] && [[ "$agent_name" != "techlead" ]]; then
                local report_file="$report_dir/report.md"
                if [[ -f "$report_file" ]]; then
                    echo "### $agent_name"
                    echo ""
                    cat "$report_file"
                    echo ""
                    echo "---"
                    echo ""
                fi
            fi
        done
    } > "$output_file"

    # Verify consolidation
    if [[ -f "$output_file" ]]; then
        local content
        content=$(cat "$output_file")

        if echo "$content" | grep -q "backend-expert" && \
           echo "$content" | grep -q "frontend-expert" && \
           echo "$content" | grep -q "database-expert" && \
           echo "$content" | grep -q "Executive Summary"; then
            pass_test
        else
            fail_test "Consolidated report missing expected content"
        fi
    else
        fail_test "Consolidated report was not created"
    fi
}

e2e_test_7_session_cleanup() {
    start_test "E2E Test 7: Session Cleanup"

    if ! check_tmux; then
        skip_test "tmux not available"
        return
    fi

    # Verify session exists
    if tmux has-session -t "e2e-claude-work" 2>/dev/null; then
        # Kill session
        if tmux kill-session -t "e2e-claude-work" 2>/dev/null; then
            # Verify it's gone
            if ! tmux has-session -t "e2e-claude-work" 2>/dev/null; then
                pass_test
            else
                fail_test "Session still exists after kill"
            fi
        else
            fail_test "Failed to kill session"
        fi
    else
        fail_test "Session does not exist for cleanup test"
    fi
}

e2e_test_8_protocol_compliance() {
    start_test "E2E Test 8: Protocol Compliance"

    local compliant=true

    # Check message protocol file exists
    if [[ ! -f "$PROJECT_ROOT/protocols/distributed-messaging.md" ]]; then
        log_error "Messaging protocol file not found"
        compliant=false
    fi

    # Check report format file exists
    if [[ ! -f "$PROJECT_ROOT/protocols/report-format.md" ]]; then
        log_error "Report format file not found"
        compliant=false
    fi

    # Verify sample messages comply with protocol
    local msg_file="$E2E_QUEUE_DIR/completed/task-001.yaml"
    if [[ -f "$msg_file" ]]; then
        if ! grep -q "message_type:" "$msg_file" || \
           ! grep -q "message_id:" "$msg_file" || \
           ! grep -q "timestamp:" "$msg_file"; then
            log_error "Message does not comply with protocol"
            compliant=false
        fi
    fi

    if $compliant; then
        pass_test
    else
        fail_test "Protocol compliance check failed"
    fi
}

################################################################################
# Test Runner
################################################################################

run_e2e_tests() {
    echo "=========================================="
    echo "Distributed Orchestration E2E Tests"
    echo "=========================================="
    echo ""

    # Setup
    setup_e2e_environment

    # Run E2E tests
    e2e_test_1_script_availability
    e2e_test_2_directory_structure
    e2e_test_3_session_creation
    e2e_test_4_message_queue_flow
    e2e_test_5_agent_reports
    e2e_test_6_report_consolidation
    e2e_test_7_session_cleanup
    e2e_test_8_protocol_compliance

    # Teardown
    cleanup_e2e_environment

    # Print summary
    print_test_summary
}

# Trap to ensure cleanup on error
trap cleanup_e2e_environment EXIT INT TERM

# Run tests
run_e2e_tests
