# Standard Agent Invocation Protocol

## Overview

This template defines the standard invocation protocol for all EM-Team reviewer agents. It ensures consistent behavior across agents and reduces token usage by eliminating redundant instructions.

## Standard Invocation Process

### When Invoked

All reviewer agents MUST follow this standard process when invoked:

```yaml
invocation_protocol:
  1. git_diff_to_see_recent_changes:
     - run: "git diff" to see recent changes
     - focus_on: modified files only
     - identify: scope of changes

  2. focus_on_modified_files_only:
     - don't_review_unrelated_files
     - don't_re_scan_entire_codebase
     - limit_review_to_changed_code

  3. begin_review_immediately:
     - skip_verbose_introductions
     - start_analysis_directly
     - provide_findings_early

  4. report_findings_in_structured_format:
     - use_consistent_severity_levels
     - provide_actionable_recommendations
     - include_code_examples_where_relevant
```

## Standard Output Format

### Finding Structure

All reviewer agents should report findings in this consistent format:

```markdown
## [Agent Name] Review Report

### Executive Summary
**Overall Status:** [✅ PASS | ⚠️ WARN | ❌ FAIL]
**Total Findings:** [N Critical, N High, N Medium, N Low]

### Findings by Severity

#### CRITICAL Issues (Must Fix - Block Deployment)
| Issue | Location | Impact | Fix |
|-------|----------|--------|-----|
| [Issue 1] | [file:line] | [Impact] | [Fix] |

#### HIGH Issues (Should Fix - Block Merge)
| Issue | Location | Impact | Fix |
|-------|----------|--------|-----|
| [Issue 1] | [file:line] | [Impact] | [Fix] |

#### MEDIUM Issues (Nice to Have)
| Issue | Location | Impact | Fix |
|-------|----------|--------|-----|
| [Issue 1] | [file:line] | [Impact] | [Fix] |

#### LOW Issues (Informational)
| Issue | Location | Impact | Fix |
|-------|----------|--------|-----|
| [Issue 1] | [file:line] | [Impact] | [Fix] |

### Recommendations
1. [Priority recommendation 1]
2. [Priority recommendation 2]

### Completion Marker
## ✅ [AGENT_NAME]_COMPLETE
```

## Severity Classification

```yaml
severity_levels:
  CRITICAL:
    description: "Must fix before deployment"
    examples:
      - security_vulnerabilities (SQL injection, XSS, etc.)
      - data_loss_possible
      - system_crash_likely
      - authentication_bypass

  HIGH:
    description: "Should fix before merge"
    examples:
      - performance_regression
      - accessibility_issues
      - breaking_changes
      - security_best_practices

  MEDIUM:
    description: "Fix before next release"
    examples:
      - code_smells
      - maintainability_issues
      - minor_performance_issues
      - missing_documentation

  LOW:
    description: "Informational"
    examples:
      - style_issues
      - minor_improvements
      - suggestions
      - nice_to_have
```

## Agent-Specific Customizations

### Security Reviewer
```yaml
focus:
  - owasp_top_10
  - stride_threat_modeling
  - security_best_practices

reference: "skills/quality/security-common/SKILL.md"
```

### Code Reviewer
```yaml
focus:
  - code_quality
  - correctness
  - maintainability
  - performance

axes: 5 (correctness, security, performance, maintainability, testing)
```

### Senior Code Reviewer
```yaml
focus:
  - deep_code_analysis
  - 9_axis_review

axes: 9 (correctness, security, performance, maintainability, testing, readability, error_handling, concurrency, architecture)
```

### UI Auditor
```yaml
focus:
  - visual_consistency
  - accessibility
  - responsive_design
  - performance_metrics
```

## Best Practices

### 1. Review Only Changed Files
```yaml
✅ good:
  - review: "files in git diff"
  - analyze: "modified functions"
  - check: "affected dependencies"

❌ bad:
  - review: "entire codebase"
  - analyze: "unrelated files"
  - check: "unaffected code"
```

### 2. Provide Actionable Feedback
```yaml
✅ good:
  - "Replace string concatenation with parameterized query (line 42)"
  - "Add null check before accessing user.name (line 15)"

❌ bad:
  - "Fix security issues"
  - "Improve code quality"
```

### 3. Include Code Examples
```yaml
✅ good:
  examples:
    before: |
      // ❌ VULNERABLE
      const query = `SELECT * FROM users WHERE id = '${userId}'`;
    after: |
      // ✅ SECURE
      const query = 'SELECT * FROM users WHERE id = $1';
      await db.query(query, [userId]);

❌ bad:
  - "Fix SQL injection"
  - "Use parameterized queries"
```

### 4. Use Consistent Terminology
```yaml
terminology:
  severity: ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
  status: ["✅ PASS", "⚠️ WARN", "❌ FAIL"]
  location: "file:line or file:function"
  impact: "brief description of consequence"
  fix: "specific actionable step"
```

## Integration with Workflows

### Standard Workflow Integration
```yaml
workflow_integration:
  handoff:
    receives:
      - task_description
      - code_diff
      - context

    provides:
      - review_report
      - findings_by_severity
      - recommendations

    completion_marker:
      format: "## ✅ [AGENT_NAME]_COMPLETE"
      required: true
```

## Completion Checklist

Before marking review as complete, verify:
- [ ] Git diff reviewed
- [ ] All modified files analyzed
- [ ] Findings documented with severity
- [ ] Recommendations provided
- [ ] Code examples included (where relevant)
- [ ] Completion marker added
- [ ] Report follows standard format

---

**Template Version:** 1.0.0
**Last Updated:** 2026-04-19
**Usage:** Reference this template from all reviewer agents instead of duplicating invocation instructions
