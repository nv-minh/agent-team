# EM-Skill - Fullstack Engineering Agent/Skill/Workflow System

## Overview

EM-Skill is a comprehensive system of agents, skills, and workflows for fullstack engineering, synthesized from the best practices of 6 top AI agent/workflow repositories:

- **Product-Manager-Skills** (47 skills) - 3-tier architecture, coaching approach, interactive flows
- **agent-skills** (20 skills) - Development lifecycle, Iron Laws, 5-axis code review
- **everything-claude-code** (185+ skills) - Multi-language support, framework-specific patterns
- **get-shit-done** (GSD) - Spec-driven development, atomic commits, multi-layer QA
- **gstack** (28 skills) - Team-in-a-box, velocity multiplier, browser-in-CLI
- **superpowers** (16 skills) - Iron Laws, subagent-driven development, systematic debugging

## Project Structure

```
em-skill/
├── skills/              # ~25-30 skills
│   ├── foundation/      # Core foundational skills
│   ├── development/     # Development workflow skills
│   ├── quality/         # Quality assurance skills
│   ├── workflow/        # Workflow and automation skills
│   └── specialized/     # Language/framework-specific skills
├── agents/              # ~16-20 specialized agents (8 core + 8 specialized)
├── workflows/           # ~16 end-to-end workflows (8 primary + 8 team)
├── templates/           # Reusable templates
├── hooks/              # Automation hooks
├── commands/           # CLI commands
└── CLAUDE.md           # Main configuration (this file)
```

## Skill Categories

### Foundation Skills (5 skills)
1. **spec-driven-development** - Write specs before coding
2. **brainstorming** - Explore ideas into designs
3. **context-engineering** - Optimize agent context setup
4. **writing-plans** - Break work into bite-sized tasks
5. **systematic-debugging** - 4-phase debugging methodology

### Development Skills (8 skills)
6. **test-driven-development** - TDD RED-GREEN-REFACTOR
7. **frontend-patterns** - React/Next.js/Vue patterns
8. **backend-patterns** - API/Database patterns
9. **incremental-implementation** - Vertical slice development
10. **subagent-driven-development** - Fresh context per task
11. **source-driven-development** - Code from official docs
12. **api-interface-design** - Contract-first APIs
13. **security-hardening** - OWASP Top 10 security

### Quality Skills (7 skills)
14. **code-review** - 5-axis review framework
15. **code-simplification** - Reduce complexity
16. **browser-testing** - DevTools MCP integration
17. **performance-optimization** - Measure-first optimization
18. **e2e-testing** - Playwright patterns
19. **security-audit** - Vulnerability assessment
20. **api-testing** - Integration testing

### Workflow Skills (5 skills)
21. **git-workflow** - Atomic commits
22. **ci-cd-automation** - Feature flags, quality gates
23. **documentation** - ADRs, API docs
24. **finishing-branch** - Merge/PR decisions
25. **deprecation-migration** - Code-as-liability mindset

### Specialized Skills (Language/Framework)
26. **typescript-patterns** / **python-patterns** / **go-patterns**
27. **react-patterns** / **nextjs-patterns** / **vue-patterns**
28. **nodejs-patterns** / **django-patterns** / **nestjs-patterns**
29. **database-migrations** - Schema versioning
30. **using-git-worktrees** - Isolated workspaces

## Agent Categories

### Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - 5-axis code review
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP assessment
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

### Optional Agents
9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking

### Specialized Agents (8 agents)
13. **team-lead** - Orchestrator for team reviews (trigger: `duck:team-lead`)
14. **architect** - Architecture & technical design (trigger: `duck:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `duck:frontend`)
16. **senior-code-reviewer** - 9-axis deep code review (trigger: `duck:code-review`)
17. **database-expert** - Schema, queries, fintech patterns (trigger: `duck:database`)
18. **product-manager** - Requirements, GAP analysis, market fit (trigger: `duck:product`)
19. **security-reviewer** - OWASP Top 10, STRIDE, blocking authority (trigger: `duck:security`)
20. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `duck:staff`)

## Workflow Categories

### Primary Workflows
1. **new-feature** - From idea to production
2. **bug-fix** - Investigate and fix bugs
3. **refactoring** - Improve code quality
4. **security-audit** - Security assessment

### Support Workflows
5. **project-setup** - Initialize new projects
6. **documentation** - Generate and update docs
7. **deployment** - Deploy and monitor
8. **retro** - Learn and improve

### Team Workflows (8 workflows)
9. **team-review** - Full team review orchestrated by Team Lead
10. **architecture-review** - Architecture review with Architect & Staff Engineer
11. **design-review** - UI/UX design review with Frontend Expert & Product Manager
12. **code-review-9axis** - Deep 9-axis code review with Senior Code Reviewer & Security
13. **database-review** - Database schema & query review with Database Expert & Architect
14. **product-review** - Product/spec review with Product Manager & Architect
15. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
16. **incident-response** - Production incident handling with Staff Engineer & Security

## Iron Laws

From agent-skills and superpowers:

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Skill Iron Law**: ALL SKILLS MUST HAVE FAILING TESTS
4. **Spec Iron Law**: NO CODE WITHOUT SPEC (for features)

## Development Lifecycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SIMPLIFY → SHIP
```

## Three-Tier Boundary System

### Always Do
- Run tests before commits
- Follow naming conventions
- Validate inputs
- Write tests for new code
- Review code before shipping

### Ask First
- Database schema changes
- Adding dependencies
- Changing CI config
- Breaking changes
- Performance optimizations

### Never Do
- Commit secrets
- Edit vendor directories
- Remove failing tests without approval
- Skip code review
- Push to main without tests

## Special Features

### ✅ Browser Automation
- Headless browser for E2E testing
- DevTools MCP integration
- Visual QA capabilities
- Screenshot comparison

### ✅ MCP Integrations
- GitHub - Repository context
- Context7 - Documentation search
- Exa - Web research
- Memory - Cross-session learning
- Playwright - Browser automation

### ✅ Memory System
- Learn patterns across sessions
- Remember user preferences
- Track project conventions
- Build knowledge base

## Code Conventions

- All skills use YAML frontmatter
- Skills follow standard format: Overview, When to Use, Process, Rationalizations, Red Flags, Verification
- Agents have completion markers and handoff contracts
- Workflows have verification steps
- Templates are reusable and versioned

## Usage

### Using Skills
Invoke skills directly by name:
```
Use the brainstorming skill to explore this feature idea
Use the spec-driven-development skill to create a spec
Use the systematic-debugging skill to investigate this bug
```

### Using Agents
Dispatch agents for specialized tasks:
```
Agent: planner - Create implementation plan for feature X
Agent: code-reviewer - Review the changes in this PR
Agent: debugger - Investigate this bug systematically
```

### Using Workflows
Run end-to-end workflows:
```
Workflow: new-feature - Take this feature from idea to production
Workflow: bug-fix - Fix this bug systematically
Workflow: security-audit - Audit the codebase for security issues
```

## Tech Stack

- **Languages**: JavaScript/TypeScript, Python, Go, Rust, Java, Kotlin, PHP, C#, C++
- **Frontend**: React, Next.js, Vue, Svelte, Angular
- **Backend**: Node.js, Django, Laravel, NestJS, Spring Boot, Express
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis
- **Testing**: Jest, Playwright, Cypress, pytest
- **Tools**: Git, Docker, CI/CD, MCP

## Quality Gates

- [ ] All skills have YAML frontmatter
- [ ] All agents have completion markers
- [ ] All workflows have verification steps
- [ ] Documentation is complete
- [ ] Tests are passing
- [ ] Code review is done
- [ ] Security audit is passed

## Contributing

When adding new skills or agents:

1. Follow the established format
2. Include YAML frontmatter
3. Add verification steps
4. Test thoroughly
5. Document clearly

## Version

Current version: 1.1.0
Last updated: 2026-04-19

## License

MIT License - Feel free to use and adapt for your projects
