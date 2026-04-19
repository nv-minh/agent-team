#!/bin/bash
#
# Test Suite for Token Summarization Mechanism
# Tests token counting, Haiku summarization, and consolidation integration
#

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

# Test configuration
SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/scripts"
TOKEN_COUNTER="$SCRIPTS_DIR/token-counter.sh"
HAIKU_CLIENT="$SCRIPTS_DIR/haiku-client.sh"
CONSOLIDATE="$SCRIPTS_DIR/consolidate-reports.sh"
TEST_REPORT_DIR="/tmp/token-test-$$"

################################################################################
# Setup and Cleanup
################################################################################

setup_test() {
    # Create test directory
    mkdir -p "$TEST_REPORT_DIR"

    # Create sample reports with different sizes
    create_small_report "$TEST_REPORT_DIR/small-report.md"
    create_medium_report "$TEST_REPORT_DIR/medium-report.md"
    create_large_report "$TEST_REPORT_DIR/large-report.md"
}

cleanup_test() {
    # Clean up test artifacts
    rm -rf "$TEST_REPORT_DIR"
}

################################################################################
# Test Report Generators
################################################################################

create_small_report() {
    local file=$1

    cat > "$file" << 'EOF'
---
report_id: TEST-001
generated: 2026-04-19T12:00:00Z
agent: test-agent
task_id: task-001
status: completed
overall: pass
---

# Small Report

This is a small report for testing.

## Findings

No issues found.

EOF
}

create_medium_report() {
    local file=$1

    cat > "$file" << 'EOF'
---
report_id: TEST-002
generated: 2026-04-19T12:00:00Z
agent: test-agent
task_id: task-002
status: completed
overall: pass
---

# Medium Report

This is a medium-sized report for testing token counting.

## Executive Summary

The task was completed successfully with no major issues. All requirements were met and the system is functioning as expected.

## Detailed Findings

### Analysis Results

We conducted a thorough analysis of the system and found that everything is working correctly. The code follows best practices and meets all quality standards.

### Performance Metrics

- Response time: 100ms
- Throughput: 1000 req/s
- Error rate: 0.1%

### Security Review

No security vulnerabilities were found. All inputs are properly validated and sanitized.

## Recommendations

Continue monitoring system performance and conduct regular security audits.

EOF
}

create_large_report() {
    local file=$1

    cat > "$file" << 'EOF'
---
report_id: TEST-003
generated: 2026-04-19T12:00:00Z
agent: test-agent
task_id: task-003
status: completed
overall: pass
confidence: 0.95
---

# Large Comprehensive Report

This is a large report designed to test token counting and summarization mechanisms.

## Executive Summary

This comprehensive report details the extensive analysis conducted on the system. The investigation covered multiple aspects including architecture, performance, security, and user experience. Overall, the system is functioning well with some areas identified for improvement. The team has completed a thorough review of all components and has provided detailed findings and recommendations for future enhancements.

## Detailed Analysis

### System Architecture

The system architecture follows modern best practices with a clear separation of concerns. The frontend is built using React with TypeScript, providing type safety and improved developer experience. The backend utilizes Node.js with Express framework, offering robust API capabilities. The database layer employs PostgreSQL, ensuring data integrity and supporting complex queries.

#### Frontend Architecture

The frontend architecture is component-based, with each component responsible for a specific piece of functionality. State management is handled using Redux, allowing for predictable state updates. The routing is managed by React Router, enabling client-side navigation and improved performance.

Key frontend components include:
- User authentication and authorization
- Dashboard with real-time data visualization
- Data tables with sorting and filtering
- Forms with validation and error handling
- Notification system for user feedback

#### Backend Architecture

The backend is structured as a set of microservices, each handling a specific domain. This approach allows for independent scaling and deployment. The API layer follows REST principles, making it easy to understand and consume.

Key backend services include:
- User management service
- Authentication service
- Data processing service
- Notification service
- Reporting service

### Performance Analysis

Performance testing was conducted using industry-standard tools and methodologies. The system was subjected to various load conditions to assess its behavior under stress.

#### Load Testing Results

Under normal load (100 concurrent users):
- Average response time: 150ms
- 95th percentile: 250ms
- 99th percentile: 400ms
- Error rate: <0.01%

Under peak load (1000 concurrent users):
- Average response time: 450ms
- 95th percentile: 800ms
- 99th percentile: 1200ms
- Error rate: <0.1%

#### Performance Optimization Recommendations

1. Implement caching for frequently accessed data
2. Optimize database queries with proper indexing
3. Use CDN for static asset delivery
4. Implement lazy loading for large data sets
5. Consider implementing rate limiting

### Security Assessment

A comprehensive security assessment was conducted to identify potential vulnerabilities and ensure the system meets industry security standards.

#### Authentication and Authorization

The authentication system uses JWT tokens with secure storage and transmission. Passwords are hashed using bcrypt with appropriate work factors. Role-based access control (RBAC) is implemented to ensure users can only access resources they are authorized to use.

#### Data Protection

All sensitive data is encrypted at rest using industry-standard encryption algorithms. Data in transit is protected using TLS 1.3. Regular security audits are conducted to identify and address potential vulnerabilities.

#### Input Validation

All user inputs are validated and sanitized to prevent injection attacks. The system uses parameterized queries to prevent SQL injection. Output encoding is implemented to prevent XSS attacks.

### Critical Issues

| Issue | Impact | Fix | Effort |
|-------|--------|-----|--------|
| None found | N/A | N/A | N/A |

### High Issues

| Issue | Impact | Fix | Effort |
|-------|--------|-----|--------|
| Add rate limiting | Medium | Implement API rate limiting | 2 days |
| Improve error handling | Low | Add more detailed error messages | 1 day |

## Recommendations

### Short Term (1-2 weeks)

1. Implement the identified performance optimizations
2. Add comprehensive monitoring and alerting
3. Improve test coverage to 90%
4. Document API endpoints

### Medium Term (1-2 months)

1. Conduct load testing on a regular basis
2. Implement automated security scanning
3. Add integration tests for critical paths
4. Improve documentation and onboarding

### Long Term (3-6 months)

1. Consider implementing event-driven architecture
2. Explore machine learning for predictive analytics
3. Implement advanced caching strategies
4. Conduct scalability planning

## Conclusion

The system is well-architected and functioning correctly. The recommendations provided will help improve performance, security, and maintainability. Regular reviews and updates should be conducted to ensure the system continues to meet business requirements.

EOF
}

################################################################################
# Tests
################################################################################

# Test 1: Token counter exists and is executable
test_token_counter_exists() {
    start_test "Token counter script exists and is executable"

    if [[ -f "$TOKEN_COUNTER" && -x "$TOKEN_COUNTER" ]]; then
        pass_test
    else
        fail_test "Token counter not found or not executable"
    fi
}

# Test 2: Estimate tokens for small report
test_estimate_small_report() {
    start_test "Estimate tokens for small report"

    setup_test

    local token_count=$("$TOKEN_COUNTER" estimate "$TEST_REPORT_DIR/small-report.md")

    if [[ $token_count -gt 0 && $token_count -lt 1000 ]]; then
        pass_test
    else
        fail_test "Expected <1000 tokens, got $token_count"
    fi

    cleanup_test
}

# Test 3: Estimate tokens for large report
test_estimate_large_report() {
    start_test "Estimate tokens for large report"

    setup_test

    local token_count=$("$TOKEN_COUNTER" estimate "$TEST_REPORT_DIR/large-report.md")

    if [[ $token_count -gt 500 ]]; then
        pass_test
    else
        fail_test "Expected >500 tokens, got $token_count"
    fi

    cleanup_test
}

# Test 4: Check threshold functionality
test_check_threshold() {
    start_test "Check threshold functionality"

    setup_test

    # Small report should not exceed threshold
    if "$TOKEN_COUNTER" check "$TEST_REPORT_DIR/small-report.md" 150000 2>/dev/null; then
        fail_test "Small report should not exceed threshold"
    fi

    cleanup_test
}

# Test 5: Haiku client exists and is executable
test_haiku_client_exists() {
    start_test "Haiku client script exists and is executable"

    if [[ -f "$HAIKU_CLIENT" && -x "$HAIKU_CLIENT" ]]; then
        pass_test
    else
        fail_test "Haiku client not found or not executable"
    fi
}

# Test 6: Rule-based summarization
test_rule_based_summarization() {
    start_test "Rule-based summarization works"

    setup_test

    local input="$TEST_REPORT_DIR/large-report.md"
    local output="$TEST_REPORT_DIR/large-report.summarized.md"

    if "$HAIKU_CLIENT" summarize-rule-based "$input" "$output" >/dev/null 2>&1; then
        if [[ -f "$output" ]]; then
            # Check that summarized version is smaller
            local input_tokens=$("$TOKEN_COUNTER" estimate "$input")
            local output_tokens=$("$TOKEN_COUNTER" estimate "$output")

            if [[ $output_tokens -lt $input_tokens ]]; then
                pass_test
            else
                fail_test "Summarized version should be smaller ($output_tokens vs $input_tokens)"
            fi
        else
            fail_test "Summarized file not created"
        fi
    else
        fail_test "Rule-based summarization failed"
    fi

    cleanup_test
}

# Test 7: Consolidate reports script exists
test_consolidate_exists() {
    start_test "Consolidate reports script exists and is executable"

    if [[ -f "$CONSOLIDATE" && -x "$CONSOLIDATE" ]]; then
        pass_test
    else
        fail_test "Consolidate script not found or not executable"
    fi
}

# Test 8: Token config loaded correctly
test_token_config() {
    start_test "Token configuration loads correctly"

    source "$SCRIPTS_DIR/token-config.sh"

    if [[ -n "${TOKEN_BUDGET:-}" && -n "${SUMMARIZATION_THRESHOLD:-}" ]]; then
        if [[ $TOKEN_BUDGET -eq 200000 && $SUMMARIZATION_THRESHOLD -eq 150000 ]]; then
            pass_test
        else
            fail_test "Token config values incorrect"
        fi
    else
        fail_test "Token config not loaded"
    fi
}

# Test 9: Compare to budget functionality
test_compare_to_budget() {
    start_test "Compare to budget functionality"

    setup_test

    local output=$("$TOKEN_COUNTER" compare "$TEST_REPORT_DIR/small-report.md" 200000 2>&1)

    if echo "$output" | grep -q "Token Count Analysis:"; then
        pass_test
    else
        fail_test "Expected analysis output"
    fi

    cleanup_test
}

# Test 10: Directory statistics
test_dir_stats() {
    start_test "Directory statistics functionality"

    setup_test

    local output=$("$TOKEN_COUNTER" dir-stats "$TEST_REPORT_DIR" "*.md" 2>&1)

    if echo "$output" | grep -q "Total files:"; then
        pass_test
    else
        fail_test "Expected directory stats output"
    fi

    cleanup_test
}

################################################################################
# Test Execution
################################################################################

main() {
    echo "=========================================="
    echo "Token Summarization Test Suite"
    echo "=========================================="
    echo ""

    # Run all tests
    test_token_counter_exists
    test_estimate_small_report
    test_estimate_large_report
    test_check_threshold
    test_haiku_client_exists
    test_rule_based_summarization
    test_consolidate_exists
    test_token_config
    test_compare_to_budget
    test_dir_stats

    # Print summary
    print_test_summary
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
