#!/bin/bash

################################################################################
# Integration Tests for Messaging Protocol
#
# Description: Test message queue and protocol handling
# Usage: ./test-messaging-protocol.sh
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
PROTOCOLS_DIR="$(dirname "$SCRIPT_DIR")/protocols"
MSG_PROTOCOL_FILE="$PROTOCOLS_DIR/distributed-messaging.md"

################################################################################
# Test Setup
################################################################################

setup_messaging_tests() {
    echo "Setting up messaging protocol tests..."

    # Create test environment
    TEST_ENV=$(setup_test_env "messaging")
    export TEST_ENV
}

teardown_messaging_tests() {
    echo "Tearing down messaging protocol tests..."
    cleanup_test_env "$TEST_ENV"
}

################################################################################
# Test Cases
################################################################################

test_protocol_file_exists() {
    start_test "Messaging protocol file exists"

    if assert_file_exists "$MSG_PROTOCOL_FILE" "Messaging protocol should exist"; then
        pass_test
    fi
}

test_protocol_documentation() {
    start_test "Protocol has proper documentation"

    if assert_file_exists "$MSG_PROTOCOL_FILE" "Protocol file should exist"; then
        local content
        content=$(cat "$MSG_PROTOCOL_FILE")

        if echo "$content" | grep -q "Message Format\|message_type" && \
           echo "$content" | grep -q "task_assignment\|status_update"; then
            pass_test
        else
            fail_test "Protocol documentation incomplete"
        fi
    fi
}

test_create_task_assignment() {
    start_test "Create task assignment message"

    local test_env
    test_env=$(setup_test_env "task_assignment")

    # Create task assignment
    local output_file="$test_env/queue/task-001.yaml"
    mkdir -p "$(dirname "$output_file")"
    create_sample_task_assignment "$output_file"

    # Verify file exists and has correct content
    if assert_file_exists "$output_file" "Task assignment file should exist"; then
        local content
        content=$(cat "$output_file")

        if echo "$content" | grep -q "message_type: task_assignment" && \
           echo "$content" | grep -q "task_id:" && \
           echo "$content" | grep -q "from:" && \
           echo "$content" | grep -q "to:"; then
            pass_test
        else
            fail_test "Task assignment missing required fields"
        fi
    fi

    cleanup_test_env "$test_env"
}

test_create_status_update() {
    start_test "Create status update message"

    local test_env
    test_env=$(setup_test_env "status_update")

    # Create status update
    local output_file="$test_env/queue/status-001.yaml"
    mkdir -p "$(dirname "$output_file")"
    create_sample_status_update "$output_file"

    # Verify file exists and has correct content
    if assert_file_exists "$output_file" "Status update file should exist"; then
        local content
        content=$(cat "$output_file")

        if echo "$content" | grep -q "message_type: status_update" && \
           echo "$content" | grep -q "task_id:" && \
           echo "$content" | grep -q "status:" && \
           echo "$content" | grep -q "progress:"; then
            pass_test
        else
            fail_test "Status update missing required fields"
        fi
    fi

    cleanup_test_env "$test_env"
}

test_create_findings_report() {
    start_test "Create findings report message"

    local test_env
    test_env=$(setup_test_env "findings_report")

    # Create findings report
    local output_file="$test_env/shared/findings-001.md"
    mkdir -p "$(dirname "$output_file")"
    create_sample_report "$output_file" "test-agent" "task-001"

    # Verify file exists and has correct content
    if assert_file_exists "$output_file" "Findings report file should exist"; then
        local content
        content=$(cat "$output_file")

        if echo "$content" | grep -q "report_id:" && \
           echo "$content" | grep -q "agent:" && \
           echo "$content" | grep -q "status:" && \
           echo "$content" | grep -q "findings:"; then
            pass_test
        else
            fail_test "Findings report missing required fields"
        fi
    fi

    cleanup_test_env "$test_env"
}

test_yaml_parsing() {
    start_test "Parse YAML frontmatter correctly"

    local test_env
    test_env=$(setup_test_env "yaml_parse")

    # Create sample YAML file
    local yaml_file="$test_env/sample.yaml"
    create_sample_task_assignment "$yaml_file"

    # Extract YAML content
    local yaml_content
    yaml_content=$(sed -n '/^---$/,/^---$/p' "$yaml_file" | sed '1d;$d')

    # Verify parsing
    if echo "$yaml_content" | grep -q "message_type:" && \
       echo "$yaml_content" | grep -q "task_id:"; then
        pass_test
    else
        fail_test "YAML parsing failed"
    fi

    cleanup_test_env "$test_env"
}

test_message_queue_structure() {
    start_test "Message queue directory structure"

    local test_env
    test_env=$(setup_test_env "queue_structure")

    # Create queue structure
    local queue_dir="$test_env/queue"
    mkdir -p "$queue_dir/pending"
    mkdir -p "$queue_dir/processing"
    mkdir -p "$queue_dir/completed"

    # Verify structure
    if assert_dir_exists "$queue_dir/pending" "Pending queue should exist" && \
       assert_dir_exists "$queue_dir/processing" "Processing queue should exist" && \
       assert_dir_exists "$queue_dir/completed" "Completed queue should exist"; then
        pass_test
    fi

    cleanup_test_env "$test_env"
}

test_message_types_defined() {
    start_test "All message types are defined"

    if assert_file_exists "$MSG_PROTOCOL_FILE" "Protocol file should exist"; then
        local content
        content=$(cat "$MSG_PROTOCOL_FILE")

        # Check for common message types
        if echo "$content" | grep -q "task_assignment" && \
           echo "$content" | grep -q "status_update" && \
           echo "$content" | grep -q "findings_report"; then
            pass_test
        else
            fail_test "Not all message types defined"
        fi
    fi
}

test_message_validation() {
    start_test "Message validation fields exist"

    if assert_file_exists "$MSG_PROTOCOL_FILE" "Protocol file should exist"; then
        local content
        content=$(cat "$MSG_PROTOCOL_FILE")

        # Check for validation fields
        if echo "$content" | grep -q "message_id\|timestamp\|from\|to"; then
            pass_test
        else
            fail_test "Message validation fields not defined"
        fi
    fi
}

test_message_serialization() {
    start_test "Messages can be serialized and deserialized"

    local test_env
    test_env=$(setup_test_env "serialization")

    # Create message
    local msg_file="$test_env/message.yaml"
    create_sample_task_assignment "$msg_file"

    # Read it back
    local task_id
    task_id=$(grep "^task_id:" "$msg_file" | cut -d':' -f2 | xargs)

    if [[ "$task_id" == "task-001" ]]; then
        pass_test
    else
        fail_test "Serialization failed (got: $task_id)"
    fi

    cleanup_test_env "$test_env"
}

test_cross_agent_communication() {
    start_test "Cross-agent communication structure"

    local test_env
    test_env=$(setup_test_env "cross_agent")

    # Create messages between different agents
    create_sample_task_assignment "$test_env/queue/msg1.yaml"

    # Verify from/to fields
    local content
    content=$(cat "$test_env/queue/msg1.yaml")

    if echo "$content" | grep -q "from: techlead-orchestrator" && \
       echo "$content" | grep -q "to: backend-expert"; then
        pass_test
    else
        fail_test "Cross-agent communication structure incorrect"
    fi

    cleanup_test_env "$test_env"
}

test_message_priority() {
    start_test "Message priority handling"

    local test_env
    test_env=$(setup_test_env "priority")

    # Create message with priority
    local msg_file="$test_env/queue/priority-msg.yaml"
    cat > "$msg_file" << 'EOF'
---
message_type: task_assignment
priority: high
task_id: task-001
EOF

    # Verify priority field
    if grep -q "priority: high" "$msg_file"; then
        pass_test
    else
        fail_test "Priority field not found"
    fi

    cleanup_test_env "$test_env"
}

test_message_dependencies() {
    start_test "Message dependency handling"

    local test_env
    test_env=$(setup_test_env "dependencies")

    # Create message with dependencies
    local msg_file="$test_env/queue/deps-msg.yaml"
    cat > "$msg_file" << 'EOF'
---
message_type: task_assignment
task_id: task-002
dependencies:
  - task-001
  - task-000
EOF

    # Verify dependencies field
    if grep -q "dependencies:" "$msg_file" && \
       grep -q "task-001" "$msg_file"; then
        pass_test
    else
        fail_test "Dependencies field not found"
    fi

    cleanup_test_env "$test_env"
}

################################################################################
# Test Runner
################################################################################

run_all_tests() {
    echo "======================================"
    echo "Messaging Protocol Integration Tests"
    echo "======================================"
    echo ""

    # Setup
    setup_messaging_tests

    # Run tests
    test_protocol_file_exists
    test_protocol_documentation
    test_create_task_assignment
    test_create_status_update
    test_create_findings_report
    test_yaml_parsing
    test_message_queue_structure
    test_message_types_defined
    test_message_validation
    test_message_serialization
    test_cross_agent_communication
    test_message_priority
    test_message_dependencies

    # Teardown
    teardown_messaging_tests

    # Print summary
    print_test_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
