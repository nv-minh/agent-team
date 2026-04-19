#!/usr/bin/env bash
# TDD Context Manager for EM-Skill
# Manages failure context files and provides AI-readable summaries

set -euo pipefail

# Configuration
CONTEXT_DIR=".claude/tdd-context"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[TDD-CONTEXT]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[TDD-CONTEXT]${NC} $1"
}

log_error() {
    echo -e "${RED}[TDD-CONTEXT]${NC} $1"
}

# Get the latest failure file
get_latest_failure() {
    local latest_file="$CONTEXT_DIR/test-latest-failure.json"

    if [[ ! -f "$latest_file" ]]; then
        log_error "No failure context found at: $latest_file"
        return 1
    fi

    echo "$latest_file"
}

# List all failure files
list_failures() {
    if [[ ! -d "$CONTEXT_DIR" ]]; then
        log_warn "No context directory found"
        return 1
    fi

    local failures=($(ls -t "$CONTEXT_DIR"/test-failure-*.json 2>/dev/null))

    if [[ ${#failures[@]} -eq 0 ]]; then
        log_info "No failure files found"
        return 0
    fi

    echo ""
    echo "=== TDD Failure Files ==="
    for i in "${!failures[@]}"; do
        local file="${failures[$i]}"
        local timestamp=$(jq -r '.timestamp' "$file" 2>/dev/null || echo "unknown")
        local retry_count=$(jq -r '.retry_count' "$file" 2>/dev/null || echo "?")
        local exit_code=$(jq -r '.exit_code' "$file" 2>/dev/null || echo "?")

        printf "%2d. %s\n" $((i+1)) "$(basename "$file")"
        printf "    Time: %s, Retry: %s, Exit: %s\n" "$timestamp" "$retry_count" "$exit_code"
    done
    echo ""
}

# Format failure for AI consumption
format_failure_for_ai() {
    local failure_file="$1"

    if [[ ! -f "$failure_file" ]]; then
        log_error "Failure file not found: $failure_file"
        return 1
    fi

    local timestamp=$(jq -r '.timestamp' "$failure_file" 2>/dev/null || echo "unknown")
    local retry_count=$(jq -r '.retry_count' "$failure_file" 2>/dev/null || echo "?")
    local max_retries=$(jq -r '.max_retries' "$failure_file" 2>/dev/null || echo "?")
    local exit_code=$(jq -r '.exit_code' "$failure_file" 2>/dev/null || echo "?")
    local test_command=$(jq -r '.test_command' "$failure_file" 2>/dev/null || echo "unknown")
    local output=$(jq -r '.output' "$failure_file" 2>/dev/null || echo "No output")
    local working_dir=$(jq -r '.working_directory' "$failure_file" 2>/dev/null || echo "unknown")
    local git_branch=$(jq -r '.git_branch' "$failure_file" 2>/dev/null || echo "unknown")
    local git_commit=$(jq -r '.git_commit' "$failure_file" 2>/dev/null | cut -c1-8)

    cat << EOF

## 🔴 TDD Test Failure - RED Phase

The following test failure needs to be fixed to proceed to GREEN phase:

### Test Information
- **Command:** \`$test_command\`
- **Exit Code:** $exit_code
- **Retry Attempt:** $retry_count of $max_retries
- **Timestamp:** $timestamp
- **Location:** $working_dir
- **Git Branch:** $git_branch
- **Git Commit:** $git_commit

### Error Output
\`\`\`
$output
\`\`\`

### What To Do

1. **Analyze the error** - Understand why the test failed
2. **Write minimal code** - Implement the simplest fix to make the test pass
3. **Re-run the test** - Verify the fix works
4. **Proceed to REFACTOR** - Once green, improve the code

### TDD Iron Law
> NO PRODUCTION CODE WITHOUT FAILING TEST

This failure is expected in TDD. The goal is to make this test pass
with the minimal possible implementation.

EOF
}

# Show detailed failure information
show_failure_details() {
    local failure_file="$1"

    if [[ ! -f "$failure_file" ]]; then
        log_error "Failure file not found: $failure_file"
        return 1
    fi

    echo ""
    echo "=== Failure File Details ==="
    echo "File: $failure_file"
    echo ""

    # Pretty print JSON
    if command -v jq &> /dev/null; then
        jq '.' "$failure_file"
    else
        cat "$failure_file"
    fi
    echo ""
}

# Reset retry context
reset_retry_context() {
    local count_file="$CONTEXT_DIR/test-retry-count.txt"
    local latest_file="$CONTEXT_DIR/test-latest-failure.json"

    if [[ -f "$count_file" ]]; then
        rm "$count_file"
        log_info "Retry counter reset"
    fi

    if [[ -f "$latest_file" ]]; then
        rm "$latest_file"
        log_info "Latest failure file removed"
    fi

    log_info "TDD context reset successfully"
}

# Show retry status
show_retry_status() {
    local count_file="$CONTEXT_DIR/test-retry-count.txt"
    local latest_file="$CONTEXT_DIR/test-latest-failure.json"

    echo ""
    echo "=== TDD Retry Status ==="

    if [[ -f "$count_file" ]]; then
        local count=$(cat "$count_file")
        echo "Current retry count: $count"
    else
        echo "Current retry count: 0"
    fi

    if [[ -f "$latest_file" ]]; then
        echo "Latest failure: $latest_file"
        local timestamp=$(jq -r '.timestamp' "$latest_file" 2>/dev/null || echo "unknown")
        echo "Failure time: $timestamp"
    else
        echo "No recent failures"
    fi

    echo ""
}

# Clean up old context files
cleanup_old_context() {
    if [[ ! -d "$CONTEXT_DIR" ]]; then
        log_warn "No context directory found"
        return 0
    fi

    # Count files before cleanup
    local before_count=$(ls -1 "$CONTEXT_DIR"/test-failure-*.json 2>/dev/null | wc -l)

    # Keep only the 10 most recent failure files
    ls -t "$CONTEXT_DIR"/test-failure-*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true

    # Count files after cleanup
    local after_count=$(ls -1 "$CONTEXT_DIR"/test-failure-*.json 2>/dev/null | wc -l)

    local removed=$((before_count - after_count))
    if [[ $removed -gt 0 ]]; then
        log_info "Cleaned up $removed old failure file(s)"
    else
        log_info "No old files to clean up"
    fi
}

# Export context for external tools
export_context_for_ai() {
    local latest_file="$CONTEXT_DIR/test-latest-failure.json"

    if [[ ! -f "$latest_file" ]]; then
        log_error "No failure context found"
        return 1
    fi

    # Output the file path for easy consumption
    echo "$latest_file"
}

# Validate context file integrity
validate_context() {
    local failure_file="$1"

    if [[ ! -f "$failure_file" ]]; then
        log_error "File not found: $failure_file"
        return 1
    fi

    # Check if it's valid JSON
    if ! jq empty "$failure_file" 2>/dev/null; then
        log_error "Invalid JSON in: $failure_file"
        return 1
    fi

    # Check required fields
    local required_fields=("timestamp" "retry_count" "max_retries" "exit_code" "test_command" "output")
    local missing_fields=()

    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$failure_file" &>/dev/null; then
            missing_fields+=("$field")
        fi
    done

    if [[ ${#missing_fields[@]} -gt 0 ]]; then
        log_error "Missing required fields: ${missing_fields[*]}"
        return 1
    fi

    log_info "Context file is valid: $failure_file"
    return 0
}

# Main entry point
main() {
    case "${1:-}" in
        latest)
            get_latest_failure
            ;;
        list)
            list_failures
            ;;
        format)
            local file="${2:-$(get_latest_failure)}"
            if [[ -f "$file" ]]; then
                format_failure_for_ai "$file"
            else
                log_error "No failure file to format"
                exit 1
            fi
            ;;
        details)
            local file="${2:-$(get_latest_failure)}"
            show_failure_details "$file"
            ;;
        reset)
            reset_retry_context
            ;;
        status)
            show_retry_status
            ;;
        cleanup)
            cleanup_old_context
            ;;
        export)
            export_context_for_ai
            ;;
        validate)
            local file="${2:-$(get_latest_failure)}"
            validate_context "$file"
            ;;
        *)
            echo "Usage: $0 {latest|list|format|details|reset|status|cleanup|export|validate}"
            echo ""
            echo "Commands:"
            echo "  latest              - Get path to latest failure file"
            echo "  list                - List all failure files"
            echo "  format [file]       - Format failure for AI consumption"
            echo "  details [file]      - Show detailed failure information"
            echo "  reset               - Reset all retry context"
            echo "  status              - Show current retry status"
            echo "  cleanup             - Remove old failure files"
            echo "  export              - Export latest failure path for external tools"
            echo "  validate [file]     - Validate context file integrity"
            echo ""
            echo "Examples:"
            echo "  $0 format           - Format latest failure for AI"
            echo "  $0 list             - List all failures"
            echo "  $0 reset            - Clear retry context"
            exit 1
            ;;
    esac
}

# If script is executed (not sourced), run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
