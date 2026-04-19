#!/usr/bin/env bash
# TDD Auto-Retry Wrapper for EM-Team
# Implements RED-GREEN-REFACTOR cycle with automatic retry logic
# Exit codes: 0=success, 42=retry available, 43=max retries exceeded

set -euo pipefail

# Configuration
MAX_RETRIES=3
CONTEXT_DIR=".claude/tdd-context"
delays=(1 2 4)  # Exponential backoff in seconds

# Ensure context directory exists
mkdir -p "$CONTEXT_DIR"

# Exit codes
EXIT_CODE_SUCCESS=0
EXIT_CODE_RETRY_MORE=42
EXIT_CODE_MAX_RETRIES=43

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[TDD-RETRY]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[TDD-RETRY]${NC} $1"
}

log_error() {
    echo -e "${RED}[TDD-RETRY]${NC} $1"
}

# Get current retry count
get_retry_count() {
    local count_file="$CONTEXT_DIR/test-retry-count.txt"
    if [[ -f "$count_file" ]]; then
        cat "$count_file"
    else
        echo "0"
    fi
}

# Increment retry count
increment_retry_count() {
    local count_file="$CONTEXT_DIR/test-retry-count.txt"
    local current=$(get_retry_count)
    local next=$((current + 1))
    echo "$next" > "$count_file"
    echo "$next"
}

# Reset retry count (called on success)
reset_retry_count() {
    local count_file="$CONTEXT_DIR/test-retry-count.txt"
    if [[ -f "$count_file" ]]; then
        rm "$count_file"
        log_info "Retry counter reset"
    fi
}

# Capture error context to JSON
capture_error_context() {
    local output_file="$1"
    local retry_num="$2"
    local test_command="$3"
    local exit_code="$4"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local failure_file="$CONTEXT_DIR/test-failure-${timestamp}.json"

    # Get git context
    local git_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local git_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    local working_dir=$(pwd)

    # Read test output
    local test_output=$(cat "$output_file" 2>/dev/null || echo "No output captured")

    # Create JSON
    cat > "$failure_file" << EOF
{
  "timestamp": "$timestamp",
  "retry_count": $retry_num,
  "max_retries": $MAX_RETRIES,
  "exit_code": $exit_code,
  "test_command": "$test_command",
  "output": $(echo "$test_output" | jq -Rs .),
  "working_directory": "$working_dir",
  "git_branch": "$git_branch",
  "git_commit": "$git_commit"
}
EOF

    log_info "Error context saved to: $failure_file"

    # Also save as latest for easy access
    local latest_file="$CONTEXT_DIR/test-latest-failure.json"
    cp "$failure_file" "$latest_file"
}

# Format failure for AI consumption
format_failure_for_ai() {
    local failure_file="$1"

    if [[ ! -f "$failure_file" ]]; then
        echo "No failure context found"
        return 1
    fi

    # Parse JSON and format
    local timestamp=$(jq -r '.timestamp' "$failure_file")
    local retry_count=$(jq -r '.retry_count' "$failure_file")
    local max_retries=$(jq -r '.max_retries' "$failure_file")
    local exit_code=$(jq -r '.exit_code' "$failure_file")
    local test_command=$(jq -r '.test_command' "$failure_file")
    local output=$(jq -r '.output' "$failure_file")

    cat << EOF

## TDD Test Failure Context

The following test failure needs to be fixed:

**Test Command:** \`$test_command\`
**Exit Code:** $exit_code
**Retry:** $retry_count/$max_retries
**Timestamp:** $timestamp

### Error Output:
\`\`\`
$output
\`\`\`

### Next Steps:
1. Analyze the test failure
2. Fix the underlying issue
3. Re-run the test to verify the fix

EOF
}

# Clean up old context files
cleanup_old_context() {
    # Keep only the 10 most recent failure files
    ls -t "$CONTEXT_DIR"/test-failure-*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
}

# Main retry logic
run_tdd_with_retry() {
    local test_command="$1"
    local max_retries_override="${2:-$MAX_RETRIES}"

    # Override max retries if provided
    if [[ "$max_retries_override" != "$MAX_RETRIES" ]]; then
        MAX_RETRIES="$max_retries_override"
    fi

    local retry_count=$(get_retry_count)
    local temp_output=$(mktemp)

    log_info "Starting TDD test run (retry $retry_count/$MAX_RETRIES)"
    log_info "Command: $test_command"

    # Run test
    if eval "$test_command" 2>&1 | tee "$temp_output"; then
        # Success
        rm -f "$temp_output"
        reset_retry_count
        log_info "✓ Tests passed!"

        # Clean up old context files
        cleanup_old_context

        return $EXIT_CODE_SUCCESS
    fi

    # Failure - capture context
    local exit_code=$?
    log_warn "✗ Tests failed with exit code: $exit_code"

    # Increment retry count
    retry_count=$(increment_retry_count)

    # Capture error context
    capture_error_context "$temp_output" "$retry_count" "$test_command" "$exit_code"
    rm -f "$temp_output"

    # Check if we should retry
    if [[ $retry_count -lt $MAX_RETRIES ]]; then
        # Calculate delay (exponential backoff)
        local delay_index=$((retry_count - 1))
        local delay=${delays[$delay_index]-1}

        log_warn "Retrying in ${delay}s... (retry $retry_count/$MAX_RETRIES)"

        # Display AI-friendly message
        echo ""
        format_failure_for_ai "$CONTEXT_DIR/test-latest-failure.json"

        sleep "$delay"
        return $EXIT_CODE_RETRY_MORE
    else
        # Max retries exceeded
        log_error "Max retries ($MAX_RETRIES) exceeded. Manual intervention required."

        # Display AI-friendly message
        echo ""
        format_failure_for_ai "$CONTEXT_DIR/test-latest-failure.json"

        return $EXIT_CODE_MAX_RETRIES
    fi
}

# Show current retry status
show_retry_status() {
    local count=$(get_retry_count)
    local latest_file="$CONTEXT_DIR/test-latest-failure.json"

    echo ""
    echo "=== TDD Retry Status ==="
    echo "Current retry count: $count/$MAX_RETRIES"

    if [[ -f "$latest_file" ]]; then
        echo "Latest failure: $latest_file"
        echo ""
        echo "Latest error summary:"
        format_failure_for_ai "$latest_file"
    else
        echo "No recent failures"
    fi
    echo ""
}

# Main entry point
main() {
    case "${1:-}" in
        run)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 run <test-command> [max-retries]"
                exit 1
            fi
            run_tdd_with_retry "$2" "${3:-$MAX_RETRIES}"
            ;;
        status)
            show_retry_status
            ;;
        reset)
            reset_retry_count
            log_info "Retry counter reset manually"
            ;;
        format)
            local latest_file="$CONTEXT_DIR/test-latest-failure.json"
            if [[ -f "$latest_file" ]]; then
                format_failure_for_ai "$latest_file"
            else
                log_error "No failure context found"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {run|status|reset|format}"
            echo ""
            echo "Commands:"
            echo "  run <test-command> [max-retries]  - Run tests with retry logic"
            echo "  status                            - Show current retry status"
            echo "  reset                             - Reset retry counter"
            echo "  format                            - Format latest failure for AI"
            exit 1
            ;;
    esac
}

# If script is executed (not sourced), run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
