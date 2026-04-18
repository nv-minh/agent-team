---
name: documentation
description: Documentation generation and update workflow
---

# Documentation Workflow

## Overview

The documentation workflow generates, updates, and maintains project documentation including API docs, architecture docs, and user guides.

## When to Use

- Generating documentation
- Updating existing docs
- Creating API references
- Writing architecture docs
- Documenting features

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ANALYZE → GENERATE → REVIEW → UPDATE → PUBLISH        │
│     1          2           3         4          5        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Documentation Types

### 1. API Documentation

```markdown
# API Reference

## Authentication

All API requests require authentication:

\`\`\`http
Authorization: Bearer YOUR_TOKEN_HERE
\`\`\`

## Users

### Create User

\`\`\`http
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
\`\`\`
```

### 2. Architecture Documentation

```markdown
# Architecture

## System Overview

\`\`\`
┌─────────────┐      ┌─────────────┐
│             │      │             │
│  Frontend   │─────▶│  Backend    │
│  (React)    │      │  (Node.js)  │
│             │      │             │
└─────────────┘      └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │             │
                    │  Database   │
                    │ (PostgreSQL)│
                    │             │
                    └─────────────┘
\`\`\`
```

## Handoff Contracts

### Analyze → Generate

```yaml
handoff:
  from: manual
  to: executor
  provides:
    - documentation_scope
    - code_analysis
  expects:
    - documentation_generated
    - examples_working
```

## Quality Gates Summary

```yaml
quality_gates:
  analyze:
    - scope_defined
    - code_analyzed
    - requirements_clear

  generate:
    - api_docs_complete
    - architecture_documented
    - examples_working
    - diagrams_accurate

  review:
    - documentation_accurate
    - examples_tested
    - code_snippets_work
    - no_errors_found

  update:
    - issues_fixed
    - examples_working
    - links_working
    - clarity_improved

  publish:
    - documentation_deployed
    - links_working
    - team_notified
    - old_docs_archived
```

## Timeline Estimate

```yaml
timeline:
  analyze: "30 min - 2 hours"
  generate: "2-6 hours"
  review: "1-2 hours"
  update: "1-4 hours"
  publish: "30 min - 1 hour"

  total_simple: "4-8 hours"
  total_complex: "1-2 days"
```

## Success Criteria

A successful documentation workflow:

- [ ] Documentation complete
- [ ] API reference accurate
- [ ] Examples tested and working
- [ ] Architecture documented
- [ ] User guides clear
- [ ] Diagrams accurate
- [ ] Documentation published
- [ ] Team can find information
