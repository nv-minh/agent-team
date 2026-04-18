---
name: retro
description: Engineering retrospective workflow for learning and improvement
---

# Retro Workflow

## Overview

The retro workflow conducts engineering retrospectives to learn from completed work, identify improvements, and continuously enhance processes.

## When to Use

- After project completion
- End of iteration
- After major milestones
- Quarterly reviews
- Process improvement

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  COLLECT → ANALYZE → IDENTIFY → PLAN → EXECUTE        │
│     1           2             3        4          5         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Retro Data Collection

### Commit Metrics

```yaml
commit_metrics:
  total_commits: 156
  breakdown:
    feature: 89
    fix: 34
    refactor: 18
    docs: 12
    chore: 3
```

### Quality Metrics

```yaml
quality_metrics:
  test_coverage:
    before: "75%"
    after: "82%"
    improvement: "+7%"
```

## Handoff Contracts

### Collect → Analyze

```yaml
handoff:
  from: manual
  to: code-reviewer
  provides:
    - data_collected
    - metrics_gathered
    - feedback_compiled
  expects:
    - patterns_identified
    - trends_analyzed
```

## Quality Gates Summary

```yaml
quality_gates:
  collect:
    - data_collected
    - metrics_gathered
    - feedback_compiled

  analyze:
    - patterns_identified
    - trends_analyzed
    - findings_documented

  identify:
    - successes_documented
    - issues_identified
    - improvements_prioritized

  plan:
    - plan_created
    - action_items_defined
    - owners_assigned
    - timeline_set

  execute:
    - actions_completed
    - processes_updated
    - team_informed
    - progress_tracked
```

## Timeline Estimate

```yaml
timeline:
  collect: "2-4 hours"
  analyze: "2-4 hours"
  identify: "1-2 hours"
  plan: "1-2 hours"
  execute: "Variable (1-2 weeks)"

  total_retro: "6-12 hours"
  total_execute: "As needed"
```

## Success Criteria

A successful retro workflow:

- [ ] Data collected comprehensively
- [ ] Patterns identified and analyzed
- [ ] Successes and failures documented
- [ ] Action items created
- [ ] Owners assigned
- [ ] Timeline set
- [ ] Improvements implemented
- [ ] Processes updated
- [ ] Team learns and improves
