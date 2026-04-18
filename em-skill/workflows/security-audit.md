---
name: security-audit
description: Security audit workflow for vulnerability assessment and remediation
---

# Security Audit Workflow

## Overview

The security audit workflow performs comprehensive security assessment, identifies vulnerabilities, and implements fixes following OWASP standards.

## When to Use

- Auditing code for security
- Checking for vulnerabilities
- Ensuring compliance
- Before production deployment
- After security incidents

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  SCAN → ANALYZE → REMEDIATE → VERIFY → DOCUMENT        │
│    1        2           3         4         5           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Handoff Contracts

### Scan → Analyze

```yaml
handoff:
  from: security-auditor
  to: security-auditor
  provides:
    - scan_results
    - vulnerabilities
  expects:
    - vulnerability_analysis
    - prioritized_fixes
```

### Analyze → Remediate

```yaml
handoff:
  from: security-auditor
  to: executor
  provides:
    - vulnerability_analysis
    - remediation_plan
  expects:
    - vulnerabilities_fixed
    - tests_added
```

### Remediate → Verify

```yaml
handoff:
  from: executor
  to: security-auditor
  provides:
    - fixes
    - test_results
  expects:
    - verification_results
    - compliance_status
```

## Quality Gates Summary

```yaml
quality_gates:
  scan:
    - automated_scans_complete
    - vulnerabilities_identified
    - risk_levels_assigned

  analyze:
    - vulnerabilities_analyzed
    - impact_assessed
    - remediation_planned

  remediate:
    - critical_vulnerabilities_fixed
    - high_vulnerabilities_fixed
    - tests_added
    - all_tests_pass

  verify:
    - no_critical_vulnerabilities
    - no_high_vulnerabilities
    - compliance_met
    - regressions_checked

  document:
    - findings_documented
    - fixes_documented
    - report_complete
    - team_notified
```

## Timeline Estimate

```yaml
timeline:
  scan: "30 min - 2 hours"
  analyze: "1-4 hours"
  remediate: "4 hours - 3 days"
  verify: "1-2 hours"
  document: "1-2 hours"

  total_simple: "1-2 days"
  total_complex: "3-7 days"
```

## Success Criteria

A successful security audit workflow:

- [ ] All OWASP Top 10 checked
- [ ] Critical vulnerabilities fixed
- [ ] High vulnerabilities fixed
- [ ] Security tests added
- [ ] Compliance verified
- [ ] Documentation complete
- [ ] Team trained on findings
