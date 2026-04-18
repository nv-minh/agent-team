<div align="center">

# 🚀 EM-Skill - Fullstack Engineering Agent System

### A Comprehensive System of Agents, Skills, and Workflows for Fullstack Engineering

**Version:** 1.1.0 | **Last Updated:** April 2026

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Agents](https://img.shields.io/badge/Agents-16%20%288%20core%20%2B%208%20specialized%29-brightgreen)](#)
[![Workflows](https://img.shields.io/badge/Workflows-16%20%288%20primary%20%2B%208%20team%29-orange)](#)
[![Skills](https://img.shields.io/badge/Skills-25%2B-success)](#)

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Contributing](#-contributing)

---

**Built from the best practices of 6 top AI agent/workflow repositories**

[Product-Manager-Skills](https://github.com) • [agent-skills](https://github.com) • [everything-claude-code](https://github.com) • [get-shit-done](https://github.com) • [gstack](https://github.com) • [superpowers](https://github.com)

</div>

---

## 📋 Overview

**EM-Skill** is a comprehensive fullstack engineering system that combines the power of specialized AI agents, reusable skills, and end-to-end workflows. It provides a complete toolkit for modern software development, from ideation to deployment.

### 🎯 What Makes EM-Skill Different?

- **Team-in-a-Box**: 8 specialized agents working together like a real engineering team
- **Iron Laws**: Unbreakable principles that ensure code quality (TDD, Root Cause Analysis, Spec-Driven Development)
- **Multi-Language Support**: JavaScript/TypeScript, Python, Go, Rust, Java, and more
- **Browser Automation**: Built-in E2E testing and visual QA capabilities
- **MCP Integrations**: GitHub, Context7, Exa, Memory, Playwright
- **Cross-Session Learning**: Memory system that learns patterns across sessions

---

## ✨ Features

### 🤖 16 Specialized Agents

| Core Agents (8) | Specialized Agents (8) |
|-----------------|----------------------|
| 📋 Planner | 👔 Team Lead (`duck:team-lead`) |
| ⚡ Executor | 🏗️ Architect (`duck:architect`) |
| 👁️ Code Reviewer | 🎨 Frontend Expert (`duck:frontend`) |
| 🐛 Debugger | 🔍 Senior Code Reviewer (`duck:code-review`) |
| 🧪 Test Engineer | 🗄️ Database Expert (`duck:database`) |
| 🔒 Security Auditor | 📦 Product Manager (`duck:product`) |
| 🎨 UI Auditor | 🔒 Security Reviewer (`duck:security`) |
| ✅ Verifier | 👨‍💻 Staff Engineer (`duck:staff`) |

### 🔄 16 End-to-End Workflows

**Primary Workflows:**
- `new-feature` - From idea to production
- `bug-fix` - Investigate and fix bugs systematically
- `refactoring` - Improve code quality
- `security-audit` - Security assessment

**Team Workflows:**
- `team-review` - Full team orchestration
- `architecture-review` - Architecture assessment
- `design-review` - UI/UX design review
- `code-review-9axis` - Deep 9-axis code review
- `database-review` - Database assessment
- `product-review` - Product requirements review
- `security-review-advanced` - Advanced security (OWASP + STRIDE)
- `incident-response` - Production incident handling

### 🛠️ 25+ Reusable Skills

**Foundation Skills:**
1. Spec-Driven Development
2. Brainstorming
3. Context Engineering
4. Writing Plans
5. Systematic Debugging

**Development Skills:**
6. Test-Driven Development (TDD)
7. Frontend Patterns
8. Backend Patterns
9. Incremental Implementation
10. Subagent-Driven Development
11. Source-Driven Development
12. API Interface Design
13. Security Hardening

**Quality Skills:**
14. Code Review (5-axis)
15. Code Simplification
16. Browser Testing
17. Performance Optimization
18. E2E Testing
19. Security Audit
20. API Testing

**Workflow Skills:**
21. Git Workflow
22. CI/CD Automation
23. Documentation
24. Finishing Branch
25. Deprecation & Migration

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/nv-minh/superpower-agent.git
cd superpower-agent

# Copy EM-Skill to your project
cp -r em-skill /path/to/your/project/
```

### Basic Usage

#### Using Skills

```bash
# Invoke skills directly by name
"Use the brainstorming skill to explore this feature idea"
"Use the spec-driven-development skill to create a spec"
"Use the systematic-debugging skill to investigate this bug"
```

#### Using Agents

```bash
# Dispatch agents for specialized tasks
"Agent: planner - Create implementation plan for feature X"
"Agent: code-reviewer - Review the changes in this PR"
"Agent: debugger - Investigate this bug systematically"
```

#### Using Workflows

```bash
# Run end-to-end workflows
"Workflow: new-feature - Take this feature from idea to production"
"Workflow: bug-fix - Fix this bug systematically"
"Workflow: security-audit - Audit the codebase for security issues"
```

### CLI Commands

EM-Skill provides 16 CLI commands for quick access:

**Core Commands:**
```bash
em-skill quick <task>           # Execute quick tasks
em-skill debug <bug>            # Systematic debugging
em-skill review [target]        # 5-axis code review
em-skill qa <url> [scope]       # QA testing
em-skill ship                   # Ship workflow
em-skill verify [spec]          # Verify implementation
em-skill health                 # Project health check
em-skill checkpoint <cmd>       # State management
```

**Team Commands:**
```bash
em-skill team-lead "task"       # Full team orchestration
em-skill arch-review "task"     # Architecture review
em-skill design-review "task"   # UI/UX design review
em-skill code-review-9 "task"   # 9-axis deep review
em-skill db-review "task"       # Database review
em-skill product-review "task"  # Product review
em-skill security-review "task" # Advanced security
em-skill incident "task"        # Incident response
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [CLAUDE.md](./em-skill/CLAUDE.md) | Main configuration and system overview |
| [README.md](./em-skill/README.md) | Detailed project documentation |
| [HUONG_DAN_SU_DUNG.md](./em-skill/HUONG_DAN_SU_DUNG.md) | Vietnamese user guide |
| [Commands README](./em-skill/commands/README.md) | CLI commands documentation |

### Project Structure

```
em-skill/
├── skills/              # 25+ skills organized by category
│   ├── foundation/      # Core foundational skills
│   ├── development/     # Development workflow skills
│   ├── quality/         # Quality assurance skills
│   ├── workflow/        # Workflow and automation skills
│   └── specialized/     # Language/framework-specific skills
├── agents/              # 16 specialized agents
│   ├── core/            # 8 core agents
│   └── specialized/     # 8 specialized agents
├── workflows/           # 16 end-to-end workflows
│   ├── primary/         # 8 primary workflows
│   └── team/            # 8 team workflows
├── templates/           # Reusable templates
├── hooks/              # Automation hooks
├── commands/           # CLI commands
└── CLAUDE.md           # Main configuration
```

---

## 🔥 Iron Laws

EM-Skill is built on unbreakable principles:

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Skill Iron Law**: ALL SKILLS MUST HAVE FAILING TESTS
4. **Spec Iron Law**: NO CODE WITHOUT SPEC (for features)

---

## 🛡️ Three-Tier Boundary System

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

---

## 🌐 Tech Stack Support

### Languages
JavaScript/TypeScript • Python • Go • Rust • Java • Kotlin • PHP • C# • C++

### Frontend Frameworks
React • Next.js • Vue • Svelte • Angular

### Backend Frameworks
Node.js (Express, Fastify) • Python (Django, Flask, FastAPI) • Go (Gin, Echo) • Java (Spring Boot) • PHP (Laravel)

### Databases
PostgreSQL • MySQL • MongoDB • Redis

### Testing
Jest • Playwright • Cypress • pytest

---

## 📖 Usage Examples

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

---

## 🔧 Development Lifecycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SIMPLIFY → SHIP
```

---

## 🤝 Contributing

We welcome contributions! When adding new skills or agents:

1. Follow the established format
2. Include YAML frontmatter
3. Add verification steps
4. Test thoroughly
5. Document clearly

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

---

## 📊 Quality Gates

- [ ] All skills have YAML frontmatter
- [ ] All agents have completion markers
- [ ] All workflows have verification steps
- [ ] Documentation is complete
- [ ] Tests are passing
- [ ] Code review is done
- [ ] Security audit is passed

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

EM-Skill synthesizes best practices from:

1. **Product-Manager-Skills** (47 skills) - 3-tier architecture, coaching approach
2. **agent-skills** (20 skills) - Development lifecycle, Iron Laws
3. **everything-claude-code** (185+ skills) - Multi-language support
4. **get-shit-done** (GSD) - Spec-driven development, atomic commits
5. **gstack** (28 skills) - Team-in-a-box, velocity multiplier
6. **superpowers** (16 skills) - Iron Laws, subagent-driven development

---

<div align="center">

**Built with ❤️ from the best of 6 top AI agent/workflow repositories**

[⬆ Back to Top](#-em-skill---fullstack-engineering-agent-system)

</div>
