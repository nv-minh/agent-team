---
name: incident-response
description: Production incident handling with Staff Engineer and Security Reviewer agents
---

# Incident Response Workflow

## Overview

The Incident Response workflow provides systematic production incident handling, combining the Staff Engineer's root cause analysis expertise with the Security Reviewer's security investigation capabilities. This workflow ensures incidents are investigated thoroughly and resolved effectively.

## When to Use

- Production outages
- Performance degradation
- Security incidents
- Data integrity issues
- Critical bugs in production
- Customer-impacting failures

## Workflow Stages

### Stage 1: Initial Assessment & Triage (Staff Engineer)

**Agent:** `duck:staff`

**Actions:**
- Assess incident severity (P0/P1/P2/P3)
- Understand incident scope
- Identify affected services/users
- Begin timeline reconstruction
- Gather initial data

**Input:**
- Incident report/alert
- Monitoring dashboards
- Logs
- User reports

**Output:** Initial Incident Assessment

**Quality Gate:**
- [ ] Severity assessed
- [ ] Scope identified
- [ ] Timeline started
- [ ] Initial data gathered

---

### Stage 2: Security Investigation (if applicable)

**Agent:** `duck:security`

**Actions:**
- Check for security breach
- Assess if incident is security-related
- Review audit logs
- Check for unauthorized access
- Assess data exposure

**Trigger:** Any suspicion of security involvement

**Output:** Security Investigation Report

**Quality Gate:**
- [ ] Security involvement assessed
- [ ] Breach investigation completed (if applicable)
- [ ] Audit logs reviewed
- [ ] Data exposure assessed

---

### Stage 3: Root Cause Analysis (Staff Engineer)

**Agent:** `duck:staff`

**Actions:**
- Apply 5 Whys methodology
- Create fishbone diagram
- Reconstruct complete timeline
- Identify contributing factors
- Determine root cause

**Input:**
- All available logs
- Metrics
- Traces
- Monitoring data
- Team interviews

**Output:** Root Cause Analysis Report

**Quality Gate:**
- [ ] 5 Whys completed
- [ ] Root cause identified
- [ ] Contributing factors documented
- [ ] Timeline complete

---

### Stage 4: Cross-Service Impact Analysis (Staff Engineer)

**Agent:** `duck:staff`

**Actions:**
- Map affected services
- Analyze dependency impact
- Assess data integrity
- Identify cascade effects
- Document user impact

**Input:**
- System architecture
- Service dependencies
- Data flow diagrams

**Output:** Impact Analysis Report

**Quality Gate:**
- [ ] Direct impact mapped
- [ ] Indirect impact assessed
- [ ] Dependencies analyzed
- [ ] User impact documented

---

### Stage 5: Resolution & Verification (Staff Engineer + Security Reviewer)

**Agents:** `duck:staff` + `duck:security`

**Actions:**
- Implement fixes
- Verify resolution
- Assess if security patches needed
- Document temporary workarounds
- Plan permanent fixes

**Output:** Resolution Report

**Quality Gate:**
- [ ] Issue resolved
- [ ] Verification completed
- [ ] Security reviewed (if applicable)
- [ ] Documentation updated

---

### Stage 6: Postmortem & Prevention (Staff Engineer + Security Reviewer)

**Agents:** `duck:staff` + `duck:security`

**Actions:**
- Create blameless postmortem
- Identify lessons learned
- Create action items
- Update runbooks
- Improve monitoring/alerting

**Output:** Incident Postmortem Report

**Quality Gate:**
- [ ] Postmortem completed
- [ ] Lessons learned documented
- [ ] Action items created
- [ ] Prevention measures defined
- [ ] Follow-up scheduled

---

## Handoff Contracts

### To Staff Engineer
```yaml
provides:
  - incident_report
  - monitoring_data
  - logs
  - alerts
  - user_reports

expects:
  - severity_assessment
  - root_cause_analysis
  - cross_service_impact
  - resolution_plan
  - postmortem
```

### Staff Engineer → Security Reviewer
```yaml
provides:
  - incident_details
  - timeline
  - system_state
  - potential_security_concerns

expects:
  - security_investigation
  - breach_assessment
  - data_exposure_review
  - security_recommendations
```

---

## Incident Severity Levels

### P0 - Critical
```yaml
definition:
  - complete_service_outage
  - data_loss_risk
  - security_breach
  - revenue_impact > $10K/hour

response_time:
  - immediate: 0 minutes
  - investigation: 15 minutes
  - resolution: 1 hour

examples:
  - production_down
  - data_corruption
  - security_breach
  - payment_processing_failure
```

### P1 - High
```yaml
definition:
  - significant_degradation
  - major_feature_broken
  - partial_service_outage
  - revenue_impact > $1K/hour

response_time:
  - immediate: 5 minutes
  - investigation: 30 minutes
  - resolution: 4 hours

examples:
  - api_errors_50%+_requests
  - checkout_broken
  - critical_performance_regression
```

### P2 - Medium
```yaml
definition:
  - minor_degradation
  - single_feature_broken
  - non-critical_service_down
  - minimal_user_impact

response_time:
  - immediate: 15 minutes
  - investigation: 1 hour
  - resolution: 1 day

examples:
  - single_feature_broken
  - admin_panel_down
  - minor_performance_issue
```

### P3 - Low
```yaml
definition:
  - cosmetic_issue
  - documentation_error
  - minor_bug
  - no_user_impact

response_time:
  - immediate: 1 hour
  - investigation: 1 day
  - resolution: 1 week

examples:
  - ui_glitch
  - typo
  - non-blocking_bug
```

---

## Root Cause Analysis Framework

### 5 Whys Method
```yaml
example_incident: API latency increased from 50ms to 500ms

why_1: Why did latency increase?
  answer: Database queries are taking longer

why_2: Why are database queries taking longer?
  answer: Query execution time increased from 10ms to 400ms

why_3: Why did query execution time increase?
  answer: Missing index on newly added column

why_4: Why was index not added?
  answer: Migration script didn't include index creation

why_5: Why didn't migration script include index?
  answer: No code review process for database migrations

root_cause: Lack of database review process
corrective_action: Implement mandatory DB review for migrations
```

### Fishbone (Ishikawa) Diagram
```yaml
categories:
  people:
    - training_gaps
    - knowledge_sharing
    - onboarding_issues

  process:
    - workflows
    - procedures
    - standards

  technology:
    - tools
    - infrastructure
    - architecture
    - dependencies

  environment:
    - production_config
    - staging_config
    - external_dependencies

  data:
    - data_quality
    - data_volume
    - data_flow
    - data_integrity

  management:
    - planning
    - resource_allocation
    - priorities
```

---

## Blameless Postmortem Framework

### Principles
```yaml
blameless_culture:
  principles:
    - focus_on_systems_not_people
    - assume_good_intent
    - psychological_safety
    - learning_over_blame

  language:
    - avoid: "human error", "mistake", "careless"
    - use: "system failure", "process gap", "improvement opportunity"

  questions:
    - what_happened: (facts)
    - why_it_happened: (systems)
    - how_to_prevent: (learning)
    - what_to_change: (action)
```

---

## Output Template

```markdown
# Incident Response Report: [Incident Name/ID]

**Incident Date:** [Date]
**Incident ID:** [ID]
**Severity:** [P0/P1/P2/P3]
**Duration:** [Downtime/Impact duration]
**Investigators:** Staff Engineer + Security Reviewer

---

## Executive Summary

**Incident Type:** [Type]
**Root Cause:** [Clear statement]
**Impact:** [Users affected, services affected, revenue impact]
**Status:** [✅ RESOLVED | ⚠️ INVESTIGATING | 🔴 ACTIVE]

---

## Timeline

| Time (UTC) | Event | Duration | Impact |
|------------|-------|----------|--------|
| [Time] | [Event] | [Duration] | [Impact] |
| [Time] | [Event] | [Duration] | [Impact] |

---

## Initial Assessment

### Severity
**Level:** [P0/P1/P2/P3]
**Justification:** [Why this severity]

### Scope
**Affected Services:** [List]
**Affected Users:** [Count/Segment]
**Geographic Impact:** [Regions]

### Initial Data
**First Indicator:** [What alerted us]
**Detection Method:** [How we detected it]

---

## Security Investigation (if applicable)

### Security Assessment
**Security Incident:** [Yes/No]
**Breach Confirmed:** [Yes/No]
**Data Exposure:** [Yes/No]
**Unauthorized Access:** [Yes/No]

### Security Findings
| Finding | Severity | Impact | Mitigation |
|---------|----------|--------|------------|
| [Finding] | [C/H/M/L] | [Impact] | [Mitigation] |

---

## Root Cause Analysis

### 5 Whys
1. **Why:** [Question]
   **Answer:** [Answer]

2. **Why:** [Question]
   **Answer:** [Answer]

3. **Why:** [Question]
   **Answer:** [Answer]

4. **Why:** [Question]
   **Answer:** [Answer]

5. **Why:** [Question]
   **Answer:** [Answer]

### Root Cause
**ROOT CAUSE:** [Clear, concise statement]

### Contributing Factors
1. [Factor 1] - [Impact]
2. [Factor 2] - [Impact]
3. [Factor 3] - [Impact]

---

## Cross-Service Impact

### Direct Impact
| Service | Impact Level | Affected Components | Users Affected |
|---------|-------------|-------------------|----------------|
| [Service] | [H/M/L] | [Components] | [Users] |

### Indirect Impact
| Service | Impact Level | Affected Components | Users Affected |
|---------|-------------|-------------------|----------------|
| [Service] | [H/M/L] | [Components] | [Users] |

### Dependency Analysis
| Dependency | Type | Health | Risk | Mitigation |
|------------|------|--------|------|------------|
| [Dependency] | [Type] | [Health] | [Risk] | [Mitigation] |

---

## Resolution

### Immediate Actions (Completed During Incident)
- [x] [Action 1]
- [x] [Action 2]
- [x] [Action 3]

### Temporary Workarounds
[Description of workarounds applied]

### Permanent Fix
[Description of permanent fix implemented]

### Verification
[How we verified the fix worked]

---

## Postmortem

### What Went Well
✅ [What worked well]
✅ [What should be repeated]
✅ [Positive outcomes]

### What Could Be Improved
⚠️  [What could be better]
⚠️  [What should change]
⚠️  [Areas for improvement]

### Action Items

#### Immediate Actions (This Week)
- [ ] [Action 1] - [Owner] - [Due Date]
- [ ] [Action 2] - [Owner] - [Due Date]

#### Follow-up Actions (Next Sprint)
- [ ] [Action 1] - [Owner] - [Due Date]
- [ ] [Action 2] - [Owner] - [Due Date]

#### Long-term Actions (Next Quarter)
- [ ] [Action 1] - [Owner] - [Due Date]
- [ ] [Action 2] - [Owner] - [Due Date]

### Lessons Learned
1. [Lesson 1]
2. [Lesson 2]
3. [Lesson 3]

---

## Follow-up

**Review Date:** [Date for review meeting]
**Review Attendees:** [List]
**Review Goals:**
- [ ] Verify action items completed
- [ ] Assess prevention measures
- [ ] Update runbooks

---

## Appendices

### Additional Data
[Supporting data, logs, metrics]

### References
[Links to relevant docs, runbooks, postmortems]

---

**Report Generated:** [Timestamp]
**Investigated by:** Staff Engineer + Security Reviewer
```

---

## Success Criteria

- [ ] Severity assessed accurately
- [ ] Timeline reconstructed completely
- [ ] Root cause identified and validated
- [ ] Cross-service impact analyzed
- [ ] Security investigation completed (if applicable)
- [ ] Issue resolved and verified
- [ ] Blameless postmortem completed
- [ ] Action items created with owners
- [ ] Lessons learned documented
- [ ] Prevention measures defined
- [ ] Follow-up scheduled

---

## Emergency Contacts

| Role | Name | Contact |
|------|------|---------|
| On-Call Engineer | [Name] | [Contact] |
| Engineering Manager | [Name] | [Contact] |
| Security Lead | [Name] | [Contact] |
| Product Owner | [Name] | [Contact] |

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** duck:staff, duck:security
