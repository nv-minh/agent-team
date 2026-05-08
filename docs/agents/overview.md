# Agents Overview

Complete reference for all EM-Team agents (35 total: 33 active + 2 deprecated).

## Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - Code review with Standard (5-axis) and Deep (9-axis) modes
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-reviewer** - Security review with Audit (OWASP) and Review (OWASP+STRIDE) modes
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

> **v3.1.0 Change:** `code-reviewer` now includes Deep mode (9-axis, formerly `senior-code-reviewer`). `security-reviewer` now includes Audit mode (formerly `security-auditor`).

## Optional Agents (4 agents)
9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis and convention extraction
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking and optimization

## Specialized Agents (9 agents)
13. **team-lead** - Team review orchestrator (trigger: `em-agent:team-lead`)
14. **architect** - Architecture & technical design (trigger: `em-agent:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `em-agent:frontend-expert`)
16. **backend-expert** - API design, performance, auth, error handling (trigger: `em-agent:backend-expert`)
17. **senior-code-reviewer** - *DEPRECATED* — Use code-reviewer with Deep mode (trigger: `em-agent:senior-code-reviewer`)
18. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
19. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
20. **security-reviewer** - OWASP Top 10 + STRIDE, blocking authority, unified with audit mode (trigger: `em-agent:security-reviewer`)
21. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

> **Boundary:** Use **Architect** for "should we build it this way?" (design decisions). Use **Staff Engineer** for "why is this broken?" (root cause, incidents).

## New Agents (v2.0+)
22. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
23. **learn** - Knowledge management and cross-session learning
24. **autoplan** - Multi-phase review pipeline orchestrator
25. **techlead-orchestrator** - Distributed team coordination
26. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
27. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
28. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

## Expert Agents (v3.0)
29. **react-expert** - React/Next.js, hooks, state management, SSR (trigger: `em-agent:react-expert`)
30. **vue-expert** - Vue 3, Composition API, Pinia, Vue Router (trigger: `em-agent:vue-expert`)
31. **nestjs-expert** - NestJS, TypeScript backend, GraphQL, microservices (trigger: `em-agent:nestjs-expert`)
32. **devops-expert** - Docker, Kubernetes, Terraform, CI/CD, cloud (trigger: `em-agent:devops-expert`)
33. **mobile-expert** - Flutter, React Native, Android, iOS (trigger: `em-agent:mobile-expert`)
34. **spring-expert** - Spring Boot, JPA, security, microservices (trigger: `em-agent:spring-expert`)
35. **rust-expert** - Rust systems, ownership, async tokio, FFI (trigger: `em-agent:rust-expert`)

## Deprecated Agents

| Agent | Deprecated Since | Reason | Replacement |
|-------|-----------------|--------|-------------|
| senior-code-reviewer | v3.1.0 | Merged into code-reviewer as Deep mode | `em-agent:code-reviewer` with "deep review" |
| security-auditor | v3.1.0 | Merged into security-reviewer as Audit mode | `em-agent:security-reviewer` (auto-selects Audit mode) |

---

**Version:** 3.1.0
**Last Updated:** 2026-05-08

See [Usage Guide](../guides/usage-guide.md#using-agents) for details.
