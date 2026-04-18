---
name: security-review-advanced
description: Advanced security review with Security Reviewer and Staff Engineer agents (OWASP + STRIDE)
---

# Security Review (Advanced) Workflow

## Overview

The Security Review (Advanced) workflow provides comprehensive security assessment combining OWASP Top 10 evaluation with STRIDE threat modeling. It leverages the Security Reviewer's blocking authority and the Staff Engineer's deep technical investigation capabilities.

## When to Use

- Pre-deployment security assessment
- Architecture security review
- Application security audit
- Compliance verification (SOC2, PCI-DSS, HIPAA)
- Threat modeling
- Security incident postmortem

## Workflow Stages

### Stage 1: OWASP Top 10 Assessment (Security Reviewer)

**Agent:** `duck:security`

**Actions:**
- Comprehensive OWASP Top 10 review:
  - A01: Broken Access Control
  - A02: Cryptographic Failures
  - A03: Injection
  - A04: Insecure Design
  - A05: Security Misconfiguration
  - A06: Vulnerable Components
  - A07: Authentication Failures
  - A08: Integrity Failures
  - A09: Logging Failures
  - A10: SSRF

**Input:**
- Code artifacts
- Architecture diagrams
- Infrastructure configuration
- Security context

**Output:** OWASP Assessment Report

**Quality Gate:**
- [ ] All OWASP categories assessed
- [ ] Vulnerabilities identified
- [ ] Severity classification applied
- [ ] Security scorecard completed

**BLOCKING:** CRITICAL/HIGH issues MUST block deployment

---

### Stage 2: STRIDE Threat Modeling (Security Reviewer + Staff Engineer)

**Agents:** `duck:security` + `duck:staff`

**Actions:**
- Create architecture diagram
- Identify trust boundaries
- Apply STRIDE to each component:
  - **S**poofing: Identity impersonation
  - **T**ampering: Data modification
  - **R**epudiation: Denying actions
  - **I**nformation Disclosure: Data exposure
  - **D**enial of Service: Service unavailability
  - **E**levation of Privilege: Unauthorized access

**Input:**
- System architecture
- Data flows
- Component list
- Security context

**Output:** STRIDE Threat Model

**Quality Gate:**
- [ ] Architecture diagram created
- [ ] Trust boundaries identified
- [ ] All STRIDE categories applied
- [ ] Threats mitigated

---

### Stage 3: Deep Security Investigation (Staff Engineer)

**Agent:** `duck:staff`

**Actions:**
- Cross-service security impact analysis
- Dependency security assessment
- Supply chain vulnerability review
- Infrastructure security evaluation
- Security architecture review

**Input:**
- OWASP findings
- STRIDE model
- System context

**Output:** Staff Security Investigation Report

**Quality Gate:**
- [ ] Cross-service impact analyzed
- [ ] Dependencies assessed
- [ ] Supply chain reviewed
- [ ] Infrastructure evaluated

---

### Stage 4: Consolidated Security Assessment

**Agents:** `duck:security` + `duck:staff`

**Actions:**
- Merge OWASP and STRIDE findings
- Identify security architecture issues
- Prioritize by combined severity and impact
- Create mitigation roadmap
- Make final security decision

**Output:** Consolidated Security Review Report

**Quality Gate:**
- [ ] All findings merged
- [ ] Architecture issues identified
- [ ] Priorities established
- [ ] Mitigations defined
- [ ] Decision documented

---

## Handoff Contracts

### To Security Reviewer
```yaml
provides:
  - code_artifacts
  - architecture_diagrams
  - infrastructure_config
  - security_context
  - compliance_requirements

expects:
  - owasp_review
  - stride_analysis
  - blocking_issues
  - security_scorecard
```

### Security Reviewer → Staff Engineer
```yaml
provides:
  - owasp_findings
  - threat_model
  - security_vulnerabilities
  - blocking_issues

expects:
  - cross_service_impact
  - dependency_analysis
  - supply_chain_review
  - infrastructure_assessment
```

---

## OWASP Top 10 Assessment Framework

### A01: Broken Access Control
```yaml
checks:
  horizontal_privilege_escalation:
    - user_can_access_other_users_data
    - insecure_direct_object_references

  vertical_privilege_escalation:
    - user_can_elevate_privileges
    - guest_can_access_admin_functions

  bypassing_authorization:
    - url_manipulation_bypasses_checks
    - missing_authorization_on_api_endpoints

  session_management:
    - session_ids_not_invalidated
    - session_timeout_not_configured
```

### A02: Cryptographic Failures
```yaml
checks:
  password_storage:
    - passwords_not_hashed
    - weak_hash_algorithm (md5, sha1)
    - no_salting

  data_in_transit:
    - no_tls
    - weak_tls_versions (tlsv1, tlsv1.1)

  data_at_rest:
    - sensitive_data_not_encrypted
    - encryption_keys_hardcoded
```

### A03: Injection
```yaml
checks:
  sql_injection:
    - concatenated_queries
    - unsanitized_user_input

  nosql_injection:
    - mongo_injection ($where, $ne)

  os_command_injection:
    - shell_command_concatenation

  ldap_injection:
    - unsanitized_input_in_filters
```

### A04: Insecure Design
```yaml
checks:
  trust_boundaries:
    - unclear_trust_boundaries
    - missing_trust_boundaries

  threat_modeling:
    - no_threat_modeling_performed
    - threats_not_identified

  security_controls:
    - security_by_obscurity
    - defense_in_depth_missing
```

### A05: Security Misconfiguration
```yaml
checks:
  default_accounts:
    - default_credentials_not_changed

  error_handling:
    - stack_traces_exposed
    - detailed_error_messages

  security_headers:
    - missing_security_headers
    - csp_not_configured
```

### A06: Vulnerable Components
```yaml
checks:
  dependency_scanning:
    - outdated_dependencies
    - known_vulnerabilities

  version_tracking:
    - no_version_tracking
    - no_security_patches
```

### A07: Authentication Failures
```yaml
checks:
  authentication:
    - weak_password_policy
    - no_account_lockout
    - no_rate_limiting

  session_management:
    - session_ids_predictable
    - session_timeout_not_configured

  multi_factor_auth:
    - mfa_not_implemented_for_sensitive
```

### A08: Integrity Failures
```yaml
checks:
  supply_chain:
    - dependency_confusion_possible
    - compromised_dependencies

  ci_cd_integrity:
    - unprotected_ci_cd_pipelines
    - no_code_signing
```

### A09: Logging Failures
```yaml
checks:
  logging:
    - security_events_not_logged
    - insufficient_log_detail

  monitoring:
    - no_security_monitoring
    - no_alerting_on_suspicious_activity
```

### A10: SSRF
```yaml
checks:
  url_validation:
    - user_can_control_urls
    - no_url_validation
    - internal_urls_accessible
```

---

## STRIDE Threat Modeling Framework

### Spoofing
```yaml
description: impersonating_something_or_someone_else
threats:
  - spoofed_user_authentication
  - spoofed_api_endpoint
  - spoofed_domain

mitigations:
  - strong_authentication
  - mutual_tls
  - certificate_pinning
```

### Tampering
```yaml
description: modifying_data_or_code
threats:
  - data_modified_in_transit
  - code_modified_at_rest
  - parameter_tampering

mitigations:
  - encryption_in_transit
  - digital_signatures
  - hash_based_signatures
```

### Repudiation
```yaml
description: users_denying_their_actions
threats:
  - no_audit_trail
  - shared_credentials

mitigations:
  - comprehensive_logging
  - digital_signatures
  - audit_trail
```

### Information Disclosure
```yaml
description: exposing_information_to_unauthorized_parties
threats:
  - data_leakage
  - sensitive_data_exposure
  - insufficient_encryption

mitigations:
  - encryption_at_rest
  - access_controls
  - data_masking
```

### Denial of Service
```yaml
description: denying_service_to_legitimate_users
threats:
  - resource_exhaustion
  - flooding_attacks

mitigations:
  - rate_limiting
  - resource_quotas
  - circuit_breakers
```

### Elevation of Privilege
```yaml
description: gaining_unauthorized_capabilities
threats:
  - privilege_escalation
  - horizontal_escalation
  - vertical_escalation

mitigations:
  - principle_of_least_privilege
  - role_based_access_control
  - regular_audits
```

---

## Blocking Authority

### CRITICAL Issues (BLOCKS Deployment)
- SQL injection vulnerability
- Authentication bypass
- Sensitive data exposure
- Remote code execution
- Hardcoded secrets/keys

### HIGH Issues (BLOCKS Merge)
- XSS vulnerability
- Weak password hashing
- Missing authorization
- CSRF vulnerability
- Known vulnerable dependencies

---

## Output Template

```markdown
# Security Review Report (Advanced): [Project/Feature]

**Review Date:** [Date]
**Reviewers:** Security Reviewer + Staff Engineer
**Project/Feature:** [Name]

---

## Executive Summary

**Overall Security Score:** [Score]/10
**Critical Issues:** [Count]
**High Issues:** [Count]
**Medium Issues:** [Count]
**Low Issues:** [Count]
**Blocking Status:** [🔴 BLOCKED | ⚠️ CONDITIONAL | ✅ APPROVED]

---

## OWASP Top 10 Assessment

### A01: Broken Access Control
**Status:** [✅ SECURE | ⚠️ NEEDS IMPROVEMENT | ❌ VULNERABLE]
**Score:** [X]/10

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [Location] | [Fix] |

---

### A02-A10: [Repeat for each category]

---

## STRIDE Threat Model

### Architecture Overview
[Architecture diagram description]

### Trust Boundaries
- [Boundary 1]
- [Boundary 2]

### Threat Analysis by Component

#### Component: [Component Name]
| STRIDE | Threat | Impact | Mitigation | Status |
|--------|--------|--------|------------|--------|
| Spoofing | [Threat] | [H/M/L] | [Mitigation] | [✅/⚠️/❌] |
| Tampering | [Threat] | [H/M/L] | [Mitigation] | [✅/⚠️/❌] |
| Repudiation | [Threat] | [H/M/L] | [Mitigation] | [✅/⚠️/❌] |
| Information Disclosure | [Threat] | [H/M/L] | [Mitigation] | [✅/⚠️/❌] |
| Denial of Service | [Threat] | [H/M/L] | [Mitigation] | [✅/⚠️/❌] |
| Elevation of Privilege | [Threat] | [H/M/L] | [Mitigation] | [✅/⚠️/❌] |

---

## Cross-Service Security Impact

### Direct Impact
| Service | Impact Level | Affected Components | Users Affected |
|---------|-------------|-------------------|----------------|
| [Service] | [H/M/L] | [Components] | [Users] |

### Dependency Security
| Dependency | Type | Vulnerability | Risk | Mitigation |
|------------|------|---------------|------|------------|
| [Dependency] | [Type] | [Vulnerability] | [Risk] | [Mitigation] |

---

## Severity Table

### Critical Issues (BLOCKING - Must Fix Immediately)
| Issue | Category | Location | Impact | Fix |
|-------|----------|----------|--------|-----|
| [Issue] | [OWASP/STRIDE] | [Location] | [Impact] | [Fix] |

### High Issues (BLOCKING - Must Fix Before Merge)
| Issue | Category | Location | Impact | Fix |
|-------|----------|----------|--------|-----|
| [Issue] | [OWASP/STRIDE] | [Location] | [Impact] | [Fix] |

### Medium Issues (Fix Before Next Release)
| Issue | Category | Location | Impact | Fix |
|-------|----------|----------|--------|-----|
| [Issue] | [OWASP/STRIDE] | [Location] | [Impact] | [Fix] |

### Low Issues (Track for Future)
| Issue | Category | Location | Impact | Fix |
|-------|----------|----------|--------|-----|
| [Issue] | [OWASP/STRIDE] | [Location] | [Impact] | [Fix] |

---

## Security Scorecard

| Category | Score | Weight | Weighted Score |
|----------|-------|--------|---------------|
| OWASP A01 | [1-10] | 10% | [Score] |
| OWASP A02 | [1-10] | 10% | [Score] |
| OWASP A03 | [1-10] | 15% | [Score] |
| OWASP A04 | [1-10] | 5% | [Score] |
| OWASP A05 | [1-10] | 5% | [Score] |
| OWASP A06 | [1-10] | 10% | [Score] |
| OWASP A07 | [1-10] | 15% | [Score] |
| OWASP A08 | [1-10] | 5% | [Score] |
| OWASP A09 | [1-10] | 5% | [Score] |
| OWASP A10 | [1-10] | 10% | [Score] |
| STRIDE Coverage | [1-10] | 10% | [Score] |
| **OVERALL** | **[1-10]** | **100%** | **[Score]** |

---

## Decision

**Status:** [🔴 BLOCKED | ⚠️ CONDITIONAL | ✅ APPROVED]

**Rationale:**
[Reasoning for blocking decision]

**Critical Issues Blocking Progress:**
1. [Critical issue 1]
2. [Critical issue 2]

**High Issues Blocking Merge:**
1. [High issue 1]
2. [High issue 2]

**Conditions for Approval (if CONDITIONAL):**
- [Condition 1]
- [Condition 2]

---

## Next Steps

1. [Immediate action 1]
2. [Immediate action 2]
3. [Follow-up action]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Security Reviewer + Staff Engineer
**Authority:** This review carries BLOCKING authority for CRITICAL and HIGH issues
```

---

## Success Criteria

- [ ] All OWASP Top 10 categories reviewed
- [ ] STRIDE threat modeling completed
- [ ] Cross-service impact analyzed
- [ ] Dependencies assessed
- [ ] Infrastructure evaluated
- [ ] Blocking issues identified
- [ ] Severity classification applied
- [ ] Security scorecard completed
- [ ] Mitigations defined
- [ ] Decision documented

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** duck:security, duck:staff
