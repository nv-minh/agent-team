---
name: refactoring
description: Code refactoring workflow for improving quality and maintainability
---

# Refactoring Workflow

## Overview

The refactoring workflow improves code quality while maintaining functionality. It focuses on reducing complexity, eliminating duplication, and enhancing maintainability.

## When to Use

- Improving code quality
- Reducing complexity
- Eliminating technical debt
- Enhancing maintainability
- Optimizing performance

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ANALYZE → PLAN → REFACTOR → VERIFY → UPDATE           │
│     1        2         3         4         5            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Handoff Contracts

### Analyze → Plan

```yaml
handoff:
  from: code-reviewer
  to: planner
  provides:
    - code_smells
    - complexity_metrics
  expects:
    - refactoring_plan
    - task_breakdown
```

### Plan → Refactor

```yaml
handoff:
  from: planner
  to: executor
  provides:
    - refactoring_plan
    - tasks
  expects:
    - refactored_code
    - tests_passing
```

### Refactor → Verify

```yaml
handoff:
  from: executor
  to: verifier
  provides:
    - refactored_code
    - test_results
  expects:
    - verification_report
    - metrics_comparison
```

## Quality Gates Summary

```yaml
quality_gates:
  analyze:
    - code_smells_identified
    - metrics_collected
    - priorities_set

  plan:
    - tasks_defined
    - tests_planned
    - no_functionality_changes

  refactor:
    - tests_pass
    - functionality_unchanged
    - quality_improved
    - complexity_reduced

  verify:
    - functionality_preserved
    - quality_improved
    - complexity_reduced
    - no_regressions

  update:
    - documentation_updated
    - tests_updated
    - changes_committed
    - debt_tracked
```

## Timeline Estimate

```yaml
timeline:
  analyze: "1-2 hours"
  plan: "1-2 hours"
  refactor: "2-8 hours (depends on scope)"
  verify: "1-2 hours"
  update: "30 min - 1 hour"

  total_simple: "4-8 hours"
  total_complex: "1-3 days"
```

## Success Criteria

A successful refactoring workflow:

- [ ] Code quality improved
- [ ] Complexity reduced
- [ ] Duplication eliminated
- [ ] Tests still pass
- [ ] Functionality unchanged
- [ ] Performance maintained or improved
- [ ] Documentation updated
- [ ] Technical debt reduced
