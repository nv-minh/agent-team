---
name: deployment
description: Deployment workflow with testing, monitoring, and rollback
---

# Deployment Workflow

## Overview

The deployment workflow manages safe, tested deployments with monitoring and rollback capabilities. It ensures reliable production releases.

## When to Use

- Deploying to production
- Deploying to staging
- Rolling out features
- Emergency deployments
- Infrastructure updates

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  PREP → DEPLOY → TEST → MONITOR → FINALIZE            │
│    1        2         3         4          5            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Deployment Strategies

### Blue-Green Deployment

```yaml
strategy: blue_green
description: "Maintain two production environments"

steps:
  - name: "Deploy to green"
    action: "Deploy new version to green environment"

  - name: "Test green"
    action: "Run smoke tests on green"

  - name: "Switch traffic"
    action: "Update load balancer to point to green"

  - name: "Monitor"
    action: "Monitor for issues for 30 minutes"

  - name: "Cleanup"
    action: "If successful, blue becomes new green"
```

### Canary Deployment

```yaml
strategy: canary
description: "Gradually roll out to subset of users"

steps:
  - name: "Deploy canary"
    action: "Deploy to 10% of servers"

  - name: "Monitor canary"
    action: "Monitor metrics for 15 minutes"

  - name: "Check metrics"
    action: "If error rate < threshold, proceed"

  - name: "Rollout to rest"
    action: "Deploy to remaining 90%"

  - name: "Final monitoring"
    action: "Monitor for 1 hour"
```

### Rolling Deployment

```yaml
strategy: rolling
description: "Gradually replace instances"

steps:
  - name: "Deploy to first batch"
    action: "Deploy to 25% of servers"

  - name: "Monitor first batch"
    action: "Monitor for 5 minutes"

  - name: "Continue rollout"
    action: "Deploy to next 25%"

  - name: "Repeat"
    action: "Continue until all deployed"
```

## Monitoring Metrics

```yaml
metrics:
  application:
    - "Response time (p50, p95, p99)"
    - "Error rate (%)"
    - "Request rate (req/s)"
    - "CPU usage (%)"
    - "Memory usage (%)"

  business:
    - "Active users"
    - "Conversion rate"
    - "Transaction volume"
    - "Revenue"

  infrastructure:
    - "Server health"
    - "Database connections"
    - "Cache hit rate"
    - "Network latency"
```

## Rollback Plan

```yaml
rollback:
  triggers:
    - "Error rate > 1%"
    - "Response time p95 > 2x baseline"
    - "Critical errors detected"
    - "Manual trigger"

  steps:
    - name: "Trigger rollback"
      action: "Execute rollback procedure"

    - name: "Verify rollback"
      action: "Verify old version is live"

    - name: "Investigate"
      action: "Investigate what went wrong"

    - name: "Document"
      action: "Document incident and resolution"
```

## Quality Gates Summary

```yaml
quality_gates:
  prepare:
    - tests_pass
    - build_succeeds
    - tag_created
    - backup_complete

  deploy:
    - staging_tests_pass
    - deployment_successful
    - smoke_tests_pass
    - traffic_shifted

  test:
    - smoke_tests_pass
    - critical_paths_work
    - error_rates_acceptable
    - performance_acceptable

  monitor:
    - metrics_normal
    - error_rates_low
    - performance_acceptable
    - no_critical_errors

  finalize:
    - deployment_successful
    - documentation_updated
    - team_notified
    - deployment_recorded
```

## Timeline Estimate

```yaml
timeline:
  prepare: "30 min - 1 hour"
  deploy: "30 min - 2 hours"
  test: "30 min - 1 hour"
  monitor: "1-4 hours"
  finalize: "30 min - 1 hour"

  total: "3-8 hours"
```

## Success Criteria

A successful deployment workflow:

- [ ] All tests pass before deployment
- [ ] Deployment completes successfully
- [ ] Smoke tests pass
- [ ] Critical paths working
- [ ] Error rates acceptable
- [ ] Performance within targets
- [ ] No regressions
- [ ] Monitoring active
- [ ] Rollback plan ready
- [ ] Documentation updated
