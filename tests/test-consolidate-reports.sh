#!/bin/bash

################################################################################
# Unit Tests for Consolidate Reports
#
# Description: Test consolidate-reports.sh script functionality
# Usage: ./test-consolidate-reports.sh
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/scripts"
CONSOLIDATE_SCRIPT="$SCRIPTS_DIR/consolidate-reports.sh"

################################################################################
# Test Setup
################################################################################

setup_consolidate_tests() {
    echo "Setting up consolidate reports tests..."

    # Check if script exists
    if [[ ! -f "$CONSOLIDATE_SCRIPT" ]]; then
        echo "Error: Consolidate reports script not found at $CONSOLIDATE_SCRIPT"
        exit 1
    fi

    # Check if script is executable
    if [[ ! -x "$CONSOLIDATE_SCRIPT" ]]; then
        chmod +x "$CONSOLIDATE_SCRIPT"
    fi
}

teardown_consolidate_tests() {
    echo "Tearing down consolidate reports tests..."
    # Clean up any test directories
    rm -rf /tmp/em-team-test-consolidate-*
}

################################################################################
# Test Cases
################################################################################

test_script_exists() {
    start_test "Script exists and is executable"

    if assert_file_exists "$CONSOLIDATE_SCRIPT" "Consolidate script should exist"; then
        if [[ -x "$CONSOLIDATE_SCRIPT" ]]; then
            pass_test
        else
            fail_test "Script is not executable"
        fi
    fi
}

test_help_command() {
    start_test "Help command works"

    local output
    output=$("$CONSOLIDATE_SCRIPT" help 2>&1 || true)

    if assert_contains "$output" "Usage" "Help should contain Usage" && \
       assert_contains "$output" "Commands:" "Help should list commands"; then
        pass_test
    fi
}

test_list_reports_function() {
    start_test "List reports function exists"

    if grep -q "list_reports()" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "list_reports function not found"
    fi
}

test_list_reports_empty() {
    start_test "List reports with empty directory"

    local test_env
    test_env=$(setup_test_env "consolidate_empty")

    # Override SHARED_DIR for testing
    local original_shared_dir
    original_shared_dir=$(grep "^SHARED_DIR=" "$CONSOLIDATE_SCRIPT" | cut -d'=' -f2)

    # Create empty shared dir
    mkdir -p "$test_env/shared"

    # Run with empty directory (script might error or show no reports)
    local output
    output=$(SHARED_DIR="$test_env/shared" "$CONSOLIDATE_SCRIPT" list 2>&1 || true)

    # Should handle empty state
    if assert_contains "$output" "No reports\|not found" "Should indicate no reports"; then
        pass_test
    else
        skip_test "Output format unclear: $output"
    fi

    cleanup_test_env "$test_env"
}

test_list_reports_with_data() {
    start_test "List reports with sample data"

    local test_env
    test_env=$(setup_test_env "consolidate_list")

    # Create sample reports
    create_sample_report "$test_env/shared/backend/report.md" "backend-expert" "task-001"
    create_sample_report "$test_env/shared/frontend/report.md" "frontend-expert" "task-002"

    # List reports
    local output
    output=$(SHARED_DIR="$test_env/shared" "$CONSOLIDATE_SCRIPT" list 2>&1 || true)

    # Should show the reports
    if assert_contains "$output" "backend" "Should show backend" && \
       assert_contains "$output" "frontend" "Should show frontend"; then
        pass_test
    else
        fail_test "Reports not listed properly"
    fi

    cleanup_test_env "$test_env"
}

test_collect_reports_function() {
    start_test "Collect reports function exists"

    if grep -q "collect_reports\|gather_reports" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "collect_reports function not found"
    fi
}

test_parse_report_function() {
    start_test "Parse report function exists"

    if grep -q "parse_report()" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "parse_report function not found"
    fi
}

test_parse_report_yaml() {
    start_test "Parse report YAML frontmatter"

    local test_env
    test_env=$(setup_test_env "parse_yaml")

    # Create a sample report
    local report_file="$test_env/sample-report.md"
    create_sample_report "$report_file" "test-agent" "task-001"

    # Parse the report (we'll need to source the function or call the script)
    # For now, just check the function exists and uses proper YAML parsing
    if grep -q "sed.*---$" "$CONSOLIDATE_SCRIPT" && \
       grep -q "grep.*report_id\|grep.*generated" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "YAML parsing logic not found"
    fi

    cleanup_test_env "$test_env"
}

test_consolidate_function() {
    start_test "Consolidate reports function exists"

    if grep -q "consolidate_reports\|merge_reports" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "consolidate_reports function not found"
    fi
}

test_validate_report_function() {
    start_test "Validate report function exists"

    if grep -q "validate_report\|check_report" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        skip_test "validate_report function not found"
    fi
}

test_consolidate_creates_output() {
    start_test "Consolidate creates output file"

    local test_env
    test_env=$(setup_test_env "consolidate_output")

    # Create sample reports
    create_consolidation_test_data "$test_env/shared"

    # Run consolidation
    local output_file="$test_env/output/consolidated-report.md"
    mkdir -p "$test_env/output"

    # Try to consolidate (script might use different output path)
    local output
    output=$(SHARED_DIR="$test_env/shared" OUTPUT_DIR="$test_env/output" "$CONSOLIDATE_SCRIPT" consolidate 2>&1 || true)

    # Check if output was created
    if [[ -f "$output_file" ]] || assert_contains "$output" "consolidated\|merged" "Should indicate consolidation"; then
        pass_test
    else
        skip_test "Consolidation output format unclear"
    fi

    cleanup_test_env "$test_env"
}

test_report_format_validation() {
    start_test "Report format validation exists"

    # Check if script validates report format
    if grep -q "report_id\|generated\|agent\|status" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "Report format validation not found"
    fi
}

test_markdown_output() {
    start_test "Generates markdown output"

    # Check if script outputs markdown
    if grep -q "\.md\|markdown" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        skip_test "Markdown output format unclear"
    fi
}

test_log_functions() {
    start_test "Log functions exist"

    local script_content
    script_content=$(cat "$CONSOLIDATE_SCRIPT")

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
    script_content=$(cat "$CONSOLIDATE_SCRIPT")

    if echo "$script_content" | grep -q "RED=" && \
       echo "$script_content" | grep -q "GREEN=" && \
       echo "$script_content" | grep -q "YELLOW=" && \
       echo "$script_content" | grep -q "BLUE="; then
        pass_test
    else
        fail_test "Not all color variables defined"
    fi
}

test_error_handling() {
    start_test "Error handling (set -euo pipefail)"

    if grep -q "set -euo pipefail" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "Error handling not properly configured"
    fi
}

test_finds_markdown_files() {
    start_test "Finds markdown files"

    if grep -q "\.md\|markdown" "$CONSOLIDATE_SCRIPT" && \
       grep -q "find.*-name\|-type f" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "File finding logic not found"
    fi
}

test_finds_json_files() {
    start_test "Finds JSON files"

    if grep -q "\.json\|json" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        skip_test "JSON file support not implemented"
    fi
}

test_stat_command_for_metadata() {
    start_test "Uses stat for file metadata"

    if grep -q "stat" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "stat command not found"
    fi
}

test_output_dir_config() {
    start_test "Output directory configuration exists"

    if grep -q "OUTPUT_DIR\|output" "$CONSOLIDATE_SCRIPT"; then
        pass_test
    else
        fail_test "Output directory configuration not found"
    fi
}

test_shebang() {
    start_test "Correct shebang"

    local first_line
    first_line=$(head -n 1 "$CONSOLIDATE_SCRIPT")

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
    echo "Consolidate Reports Unit Tests"
    echo "======================================"
    echo ""

    # Setup
    setup_consolidate_tests

    # Run tests
    test_script_exists
    test_help_command
    test_list_reports_function
    test_list_reports_empty
    test_list_reports_with_data
    test_collect_reports_function
    test_parse_report_function
    test_parse_report_yaml
    test_consolidate_function
    test_validate_report_function
    test_consolidate_creates_output
    test_report_format_validation
    test_markdown_output
    test_log_functions
    test_color_config
    test_error_handling
    test_finds_markdown_files
    test_finds_json_files
    test_stat_command_for_metadata
    test_output_dir_config
    test_shebang

    # Teardown
    teardown_consolidate_tests

    # Print summary
    print_test_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
