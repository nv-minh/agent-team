# EM-Skill - Fullstack Engineering Agent/Skill/Workflow System

> A comprehensive system of agents, skills, and workflows for fullstack engineering, synthesized from the best practices of 6 top AI agent/workflow repositories.

## Overview

EM-Skill provides a complete toolkit for fullstack engineering with:
- **25-30 Skills** - Reusable patterns and practices
- **8-12 Agents** - Specialized task handlers
- **5-8 Workflows** - End-to-end processes
- **Full Features** - Browser automation, MCP integrations, memory system

## Quick Start

### Using Skills

Invoke skills directly by name:

```bash
# Use brainstorming skill
"Use the brainstorming skill to explore this feature idea"

# Use spec-driven-development skill
"Use the spec-driven-development skill to create a spec for user authentication"

# Use systematic-debugging skill
"Use the systematic-debugging skill to investigate this bug"
```

### Using Agents

Dispatch agents for specialized tasks:

```bash
# Use planner agent
"Agent: planner - Create implementation plan for user authentication feature"

# Use code-reviewer agent
"Agent: code-reviewer - Review the changes in this PR"

# Use debugger agent
"Agent: debugger - Investigate this bug systematically"
```

### Using Workflows

Run end-to-end workflows:

```bash
# New feature workflow
"Workflow: new-feature - Take user authentication from idea to production"

# Bug fix workflow
"Workflow: bug-fix - Fix the login bug systematically"

# Security audit workflow
"Workflow: security-audit - Audit the codebase for security issues"
```

## Project Structure

```
em-skill/
├── skills/                  # 25-30 skills organized by category
│   ├── foundation/          # Core foundational skills (5)
│   ├── development/         # Development workflow skills (8)
│   ├── quality/             # Quality assurance skills (7)
│   ├── workflow/            # Workflow and automation skills (5)
│   └── specialized/         # Language/framework-specific skills
├── agents/                  # 8-12 specialized agents
├── workflows/               # 5-8 end-to-end workflows
├── templates/               # Reusable templates
│   ├── spec-template.md
│   └── plan-template.md
├── hooks/                   # Automation hooks
├── commands/                # CLI commands
└── CLAUDE.md                # Main configuration
```

## Skills

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

## Agents

### Core Agents (8 agents)

1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - 5-axis code review
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP assessment
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

### Optional Agents (4 agents)

9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking

## Workflows

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

## Special Features

### ✅ Browser Automation

- Headless browser for E2E testing
- DevTools MCP integration
- Visual QA capabilities
- Screenshot comparison

### ✅ MCP Integrations

- **GitHub** - Repository context
- **Context7** - Documentation search
- **Exa** - Web research
- **Memory** - Cross-session learning
- **Playwright** - Browser automation

### ✅ Memory System

- Learn patterns across sessions
- Remember user preferences
- Track project conventions
- Build knowledge base

## Iron Laws

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

## Tech Stack Support

### Languages
- JavaScript/TypeScript
- Python
- Go
- Rust
- Java
- Kotlin
- PHP
- C#
- C++

### Frontend Frameworks
- React
- Next.js
- Vue
- Svelte
- Angular

### Backend Frameworks
- Node.js (Express, Fastify)
- Python (Django, Flask, FastAPI)
- Go (Gin, Echo)
- Java (Spring Boot)
- PHP (Laravel)

## Quality Gates

- [ ] All skills have YAML frontmatter
- [ ] All agents have completion markers
- [ ] All workflows have verification steps
- [ ] Documentation is complete
- [ ] Tests are passing
- [ ] Code review is done
- [ ] Security audit is passed

## Usage Examples

### Example 1: Building a New Feature

```bash
# Step 1: Brainstorm the feature
"Use the brainstorming skill to explore a user authentication feature"

# Step 2: Create a spec
"Use the spec-driven-development skill to create a spec for authentication"

# Step 3: Write a plan
"Use the writing-plans skill to break down the implementation"

# Step 4: Execute the plan
"Use the subagent-driven-development skill to implement the plan"

# Step 5: Review the code
"Agent: code-reviewer - Review the authentication implementation"

# Step 6: Deploy
"Workflow: deployment - Deploy the authentication feature"
```

### Example 2: Fixing a Bug

```bash
# Step 1: Debug systematically
"Use the systematic-debugging skill to investigate the login bug"

# Step 2: Fix the root cause
# (After root cause is identified)
"Use the test-driven-development skill to fix the bug"

# Step 3: Verify the fix
"Use the api-testing skill to verify the login endpoint works"

# Step 4: Code review
"Agent: code-reviewer - Review the bug fix"
```

## Source Repositories

EM-Skill synthesizes best practices from:

1. **Product-Manager-Skills** (47 skills)
   - 3-tier architecture
   - Coaching approach
   - Interactive flows

2. **agent-skills** (20 skills)
   - Development lifecycle
   - Iron laws
   - 5-axis code review

3. **everything-claude-code** (185+ skills)
   - Multi-language support
   - Framework-specific patterns
   - MCP integrations

4. **get-shit-done** (GSD) - 24 agents, 50+ commands
   - Spec-driven development
   - Atomic commits
   - Multi-layer QA

5. **gstack** (28 skills)
   - Team-in-a-box
   - Velocity multiplier
   - Browser-in-CLI

6. **superpowers** (16 skills)
   - Iron laws
   - Subagent-driven development
   - Systematic debugging

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

**Total Counts:** Agents: 16 (8 core + 8 specialized), Workflows: 16 (8 primary + 8 team)

## License

MIT License - Feel free to use and adapt for your projects

---

**Built with ❤️ from the best of 6 top AI agent/workflow repositories**
