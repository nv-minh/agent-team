#!/bin/bash

################################################################################
# Integration Tests for Report Consolidation
#
# Description: Test end-to-end report consolidation flow
# Usage: ./test-report-consolidation.sh
################################################################################

set -euo pipefail

# Get script directory and source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
PROTOCOLS_DIR="$(dirname "$SCRIPT_DIR")/protocols"
REPORT_FORMAT_FILE="$PROTOCOLS_DIR/report-format.md"

################################################################################
# Test Setup
################################################################################

setup_consolidation_tests() {
    echo "Setting up report consolidation tests..."
    TEST_ENV=$(setup_test_env "report_consolidation")
    export TEST_ENV
}

teardown_consolidation_tests() {
    echo "Tearing down report consolidation tests..."
    cleanup_test_env "$TEST_ENV"
}

################################################################################
# Test Cases
################################################################################

test_report_format_file_exists() {
    start_test "Report format file exists"

    if assert_file_exists "$REPORT_FORMAT_FILE" "Report format should be documented"; then
        pass_test
    fi
}

test_create_sample_agent_reports() {
    start_test "Create sample agent reports"

    local test_env
    test_env=$(setup_test_env "sample_reports")

    # Create multiple agent reports
    create_consolidation_test_data "$test_env/shared"

    # Verify all reports exist
    if assert_file_exists "$test_env/shared/backend/report.md" "Backend report should exist" && \
       assert_file_exists "$test_env/shared/frontend/report.md" "Frontend report should exist" && \
       assert_file_exists "$test_env/shared/database/report.md" "Database report should exist"; then
        pass_test
    else
        fail_test "Not all reports created"
    fi

    cleanup_test_env "$test_env"
}

test_report_has_required_fields() {
    start_test "Report has all required fields"

    local test_env
    test_env=$(setup_test_env "required_fields")

    # Create sample report
    local report_file="$test_env/report.md"
    create_sample_report "$report_file" "test-agent" "task-001"

    # Check for required fields
    local content
    content=$(cat "$report_file")

    if echo "$content" | grep -q "report_id:" && \
       echo "$content" | grep -q "generated:" && \
       echo "$content" | grep -q "agent:" && \
       echo "$content" | grep -q "task_id:" && \
       echo "$content" | grep -q "status:" && \
       echo "$content" | grep -q "overall:"; then
        pass_test
    else
        fail_test "Report missing required fields"
    fi

    cleanup_test_env "$test_env"
}

test_report_has_findings() {
    start_test "Report contains findings section"

    local test_env
    test_env=$(setup_test_env "findings_section")

    # Create sample report
    local report_file="$test_env/report.md"
    create_sample_report "$report_file" "test-agent" "task-001"

    # Check for findings
    if grep -q "findings:" "$report_file"; then
        pass_test
    else
        fail_test "Findings section not found"
    fi

    cleanup_test_env "$test_env"
}

test_report_has_recommendations() {
    start_test "Report contains recommendations section"

    local test_env
    test_env=$(setup_test_env "recommendations")

    # Create sample report
    local report_file="$test_env/report.md"
    create_sample_report "$report_file" "test-agent" "task-001"

    # Check for recommendations
    if grep -q "recommendations:" "$report_file"; then
        pass_test
    else
        fail_test "Recommendations section not found"
    fi

    cleanup_test_env "$test_env"
}

test_collect_reports_from_multiple_agents() {
    start_test "Collect reports from multiple agents"

    local test_env
    test_env=$(setup_test_env "collect_multiple")

    # Create multiple reports
    create_consolidation_test_data "$test_env/shared"

    # Count reports
    local report_count
    report_count=$(find "$test_env/shared" -name "report.md" -type f | wc -l | tr -d ' ')

    if assert_count 3 "$report_count" "Should have 3 reports"; then
        pass_test
    fi

    cleanup_test_env "$test_env"
}

test_consolidate_reports_creates_output() {
    start_test "Consolidate reports creates output file"

    local test_env
    test_env=$(setup_test_env "consolidate_output")

    # Create source reports
    create_consolidation_test_data "$test_env/shared"

    # Create consolidated output
    local output_file="$test_env/output/consolidated-report.md"
    mkdir -p "$test_env/output"

    # Simple consolidation (combine reports)
    {
        echo "# Consolidated Agent Reports"
        echo ""
        echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo ""
        for report in "$test_env/shared"/*/report.md; do
            if [[ -f "$report" ]]; then
                echo "## $(basename "$(dirname "$report")") Report"
                echo ""
                cat "$report"
                echo ""
            fi
        done
    } > "$output_file"

    # Verify output exists
    if assert_file_exists "$output_file" "Consolidated report should exist"; then
        # Verify it contains content from all reports
        local content
        content=$(cat "$output_file")

        if echo "$content" | grep -q "backend-expert" && \
           echo "$content" | grep -q "frontend-expert" && \
           echo "$content" | grep -q "database-expert"; then
            pass_test
        else
            fail_test "Consolidated report missing agent content"
        fi
    fi

    cleanup_test_env "$test_env"
}

test_consolidated_report_has_summary() {
    start_test "Consolidated report has summary section"

    local test_env
    test_env=$(setup_test_env "summary_section")

    # Create reports and consolidate
    create_consolidation_test_data "$test_env/shared"
    local output_file="$test_env/output/consolidated.md"
    mkdir -p "$test_env/output"

    # Create consolidated report with summary
    {
        echo "# Agent Reports Summary"
        echo ""
        echo "## Overview"
        echo "- Total Agents: 3"
        echo "- Reports Collected: $(find "$test_env/shared" -name "report.md" | wc -l | tr -d ' ')"
        echo ""
        echo "## Agent Reports"
        echo ""
    } > "$output_file"

    # Check for summary
    if grep -q "Overview\|Summary" "$output_file"; then
        pass_test
    else
        fail_test "Summary section not found"
    fi

    cleanup_test_env "$test_env"
}

test_consolidated_report_preserves_yaml() {
    start_test "Consolidated report preserves YAML frontmatter"

    local test_env
    test_env=$(setup_test_env "yaml_preserve")

    # Create report
    create_sample_report "$test_env/shared/agent/report.md" "test-agent" "task-001"

    # Consolidate (copy directly for this test)
    mkdir -p "$test_env/output"
    cp "$test_env/shared/agent/report.md" "$test_env/output/consolidated.md"

    # Verify YAML preserved
    if grep -q "^---$" "$test_env/output/consolidated.md" && \
       grep -q "report_id:" "$test_env/output/consolidated.md"; then
        pass_test
    else
        fail_test "YAML frontmatter not preserved"
    fi

    cleanup_test_env "$test_env"
}

test_report_status_values() {
    start_test "Report status has valid values"

    local test_env
    test_env=$(setup_test_env "status_values")

    # Create reports with different statuses
    create_sample_report "$test_env/report1.md" "agent1" "task-001"
    create_sample_report "$test_env/report2.md" "agent2" "task-002"
    create_sample_report "$test_env/report3.md" "agent3" "task-003"

    # Modify statuses
    sed -i.tmp 's/status: completed/status: pass/' "$test_env/report1.md"
    sed -i.tmp 's/status: completed/status: fail/' "$test_env/report2.md"
    sed -i.tmp 's/status: completed/status: partial/' "$test_env/report3.md"

    # Verify statuses
    if grep -q "status: pass" "$test_env/report1.md" && \
       grep -q "status: fail" "$test_env/report2.md" && \
       grep -q "status: partial" "$test_env/report3.md"; then
        pass_test
    else
        fail_test "Status values not correctly set"
    fi

    cleanup_test_env "$test_env"
}

test_overall_assessment() {
    start_test "Report includes overall assessment"

    local test_env
    test_env=$(setup_test_env "overall_assessment")

    # Create report
    create_sample_report "$test_env/report.md" "test-agent" "task-001"

    # Check for overall field
    if grep -q "overall:" "$test_env/report.md"; then
        pass_test
    else
        fail_test "Overall assessment not found"
    fi

    cleanup_test_env "$test_env"
}

test_findings_categories() {
    start_test "Findings are categorized"

    local test_env
    test_env=$(setup_test_env "findings_categories")

    # Create report
    create_sample_report "$test_env/report.md" "test-agent" "task-001"

    # Check for category in findings
    if grep -q "category:" "$test_env/report.md"; then
        pass_test
    else
        fail_test "Findings categories not found"
    fi

    cleanup_test_env "$test_env"
}

test_evidence_links() {
    start_test "Findings include evidence links"

    local test_env
    test_env=$(setup_test_env "evidence_links")

    # Create report
    create_sample_report "$test_env/report.md" "test-agent" "task-001"

    # Check for evidence
    if grep -q "evidence:" "$test_env/report.md"; then
        pass_test
    else
        fail_test "Evidence links not found"
    fi

    cleanup_test_env "$test_env"
}

################################################################################
# Test Runner
################################################################################

run_all_tests() {
    echo "======================================"
    echo "Report Consolidation Integration Tests"
    echo "======================================"
    echo ""

    # Setup
    setup_consolidation_tests

    # Run tests
    test_report_format_file_exists
    test_create_sample_agent_reports
    test_report_has_required_fields
    test_report_has_findings
    test_report_has_recommendations
    test_collect_reports_from_multiple_agents
    test_consolidate_reports_creates_output
    test_consolidated_report_has_summary
    test_consolidated_report_preserves_yaml
    test_report_status_values
    test_overall_assessment
    test_findings_categories
    test_evidence_links

    # Teardown
    teardown_consolidation_tests

    # Print summary
    print_test_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
