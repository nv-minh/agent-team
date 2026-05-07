# Agents Overview

Complete reference for all EM-Team agents (35 agents total).

## Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - 5-axis code review (two-stage: spec compliance then quality)
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP assessment
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

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
17. **senior-code-reviewer** - 9-axis deep code review (trigger: `em-agent:senior-code-reviewer`)
18. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
19. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
20. **security-reviewer** - OWASP Top 10, STRIDE, blocking authority (trigger: `em-agent:security-reviewer`)
21. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

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

---

**Version:** 3.0.0
**Last Updated:** 2026-05-07

See [Usage Guide](../guides/usage-guide.md#using-agents) for details.
