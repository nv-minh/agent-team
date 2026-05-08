# Workflows Overview

Complete catalog of EM-Team workflows (24 top-level workflows + sub-workflows).

## Workflow Selection Guide

| Starting Point | Workflow |
|---|---|
| Blank directory + idea | **greenfield-app** |
| Existing codebase + feature | new-feature |
| Existing codebase + market opportunity | market-driven-feature |
| Technical bootstrapping only | project-setup |

## Primary Workflows (5 workflows)
1. **new-feature** - From idea to production (with optional market validation)
2. **greenfield-app** - From blank directory to shipped application (NEW v3.1.0)
3. **bug-fix** - Investigate and fix bugs
4. **refactoring** - Improve code quality
5. **security-audit** - Security assessment

## Support Workflows (6 workflows)
6. **project-setup** - Initialize new projects
7. **documentation** - Generate and update docs
8. **deployment** - Deploy and monitor
9. **retro** - Learn and improve
10. **ship-workflow** - Version bump, changelog, PR creation
11. **canary-monitoring** - Post-deploy health monitoring

## Master Workflow
12. **six-phase-lifecycle** - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP (all workflows inherit this)

## Team Workflows (8 workflows)
13. **team-review** - Full team review orchestrated by Team Lead
14. **architecture-review** - Architecture review with Architect & Staff Engineer
15. **design-review** - UI/UX design review with Frontend Expert & Product Manager
16. **code-review-9axis** - Deep 9-axis code review with Code Reviewer (Deep mode) & Security
17. **database-review** - Database schema & query review with Database Expert & Architect
18. **product-review** - Product/spec review with Product Manager & Architect
19. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
20. **incident-response** - Production incident handling with Staff Engineer & Security

## Distributed Workflows (2 workflows)
21. **distributed-investigation** - Parallel bug investigation across full stack
22. **distributed-development** - Parallel feature development with multiple agents

## Product Workflows (2 workflows)
23. **discovery-process** - Complete 6-stage discovery workflow (2-4 weeks)
24. **market-driven-feature** - Market-driven feature development

## Incident Sub-Workflows (`workflows/incident/`)
- **initial-triage** - First response and impact assessment
- **cross-service-impact** - Multi-service incident investigation
- **root-cause-analysis** - Systematic root cause identification
- **resolution-verification** - Verify fix and prevent regression
- **postmortem-prevention** - Postmortem and prevention measures
- **security-investigation** - Security-focused incident investigation

## Security Sub-Workflows (`workflows/security/`)
- **deep-investigation** - Deep security vulnerability investigation
- **owasp-assessment** - OWASP Top 10 assessment
- **stride-threat-modeling** - STRIDE threat modeling

---

**Version:** 3.1.0
**Last Updated:** 2026-05-08

See [Usage Guide](../guides/usage-guide.md#using-workflows) for details.
