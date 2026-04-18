---
name: project-setup
description: Project initialization workflow for new fullstack projects
---

# Project Setup Workflow

## Overview

The project setup workflow initializes new fullstack projects with proper structure, tooling, and configuration. It ensures best practices from day one.

## When to Use

- Starting new projects
- Initializing repositories
- Setting up team projects
- Creating project templates
- Bootstrapping applications

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  CHOOSE → SCAFFOLD → CONFIGURE → TEST → INITIALIZE     │
│     1         2           3         4          5          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Tech Stack Templates

### Fullstack TypeScript

```yaml
tech_stack:
  frontend: "React 18 + TypeScript + Vite"
  backend: "Node.js + Express + TypeScript"
  database: "PostgreSQL + Prisma"
  testing: "Jest + Playwright"
  tooling: "ESLint + Prettier"
  ci_cd: "GitHub Actions"

features:
  - "TypeScript strict mode"
  - "ESLint with TypeScript rules"
  - "Prettier for formatting"
  - "Husky for git hooks"
  - "Jest for testing"
  - "Playwright for E2E"
  - "GitHub Actions CI/CD"
```

## Project Structure

```yaml
structure:
  root:
    - src/
    - tests/
    - docs/
    - scripts/
    - .github/
    - config/
    - .gitignore
    - package.json
    - README.md
    - LICENSE

  src:
    - components/
    - services/
    - hooks/
    - utils/
    - types/
    - constants/
    - styles/

  tests:
    - unit/
    - integration/
    - e2e/
    - fixtures/
    - helpers/
```

## Quality Gates Summary

```yaml
quality_gates:
  choose:
    - requirements_understood
    - options_evaluated
    - decision_made
    - rationale_documented

  scaffold:
    - structure_created
    - git_initialized
    - package_json_configured
    - tooling_setup

  configure:
    - typescript_compiles
    - eslint_passes
    - tests_configured
    - build_succeeds
    - cicd_active

  test:
    - tooling_works
    - build_verifies
    - cicd_works
    - deployment_successful

  initialize:
    - initial_commit
    - repository_pushed
    - branches_created
    - protections_setup
    - team_invited
```

## Timeline Estimate

```yaml
timeline:
  choose: "30 min - 2 hours"
  scaffold: "30 min - 1 hour"
  configure: "1-2 hours"
  test: "30 min - 1 hour"
  initialize: "30 min - 1 hour"

  total: "3-7 hours"
```

## Success Criteria

A successful project setup workflow:

- [ ] Tech stack selected
- [ ] Project scaffolded
- [ ] Tooling configured
- [ ] All tools working
- [ ] CI/CD pipeline active
- [ ] Repository initialized
- [ ] Team ready to start
- [ ] Documentation complete
