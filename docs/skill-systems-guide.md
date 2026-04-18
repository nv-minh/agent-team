# Skill Systems Guide

## Overview

EM-Skill includes multiple skill systems from different sources. This guide explains when to use each system and how they integrate.

## Skill Systems

### Main Skills (`skills/`)

**Primary skill library for EM-Skill.**

**Use these for:**
- Foundation patterns (TDD, spec-driven development, systematic debugging)
- Development workflows (incremental implementation, subagent-driven development)
- Quality assurance (code review, security audit, performance optimization)
- Git/CI/CD automation (git workflow, CI/CD automation, finishing branch)
- Language/framework patterns (TypeScript, Python, React, Next.js, Node.js, Django, NestJS)
- Database patterns (migrations)

**Structure:**
```
skills/
├── foundation/       # Core foundational skills
├── development/      # Development workflow skills
├── quality/          # Quality assurance skills
└── workflow/         # Git/CI/CD automation skills
```

**Naming Convention:** Skills are named descriptively (e.g., `spec-driven-development.md` instead of `SKILL.md`)

**When to Use:**
- Default choice for all EM-Skill workflows
- When implementing features using EM-Skill agents
- When following EM-Skill development lifecycle

---

### Agent Skills (`agent-skills/skills/`)

**Legacy skill system from the agent-skills repository.**

**DEPRECATED - Migrate to main skills.**

**Status:** This system is maintained for backward compatibility but new development should use main skills.

**Use these for:**
- Legacy workflows that reference agent-skills
- Temporary compatibility during migration

**Migration Path:**
1. Identify agent-skills being used
2. Find equivalent skill in main `skills/` directory
3. Update references to point to main skills
4. Remove agent-skills dependency

---

### Product Manager Skills (`Product-Manager-Skills/skills/`)

**Product management and business analysis skills.**

**Use these for:**
- Requirements gathering
- Market analysis
- Product strategy
- User story validation
- GAP analysis
- Product-market fit assessment

**Structure:**
```
Product-Manager-Skills/skills/
├── user-story/
├── positioning-workshop/
├── product-strategy-session/
└── ... (47 total skills)
```

**Naming Convention:** Uses `SKILL.md` filename within category directories

**When to Use:**
- When Product Manager agent is invoked
- For business requirement analysis
- For product strategy work
- When validating product-market fit

**Integration:**
- Referenced by `agents/product-manager.md`
- Used in `workflows/product-review.md`
- Integrated into `workflows/team-review.md` Stage 2

---

### Everything Claude Code Skills (`everything-claude-code/`)

**Comprehensive skill library from the everything-claude-code repository.**

**Use these for:**
- Multi-language support (185+ skills across languages)
- Framework-specific patterns (React, Vue, Angular, Svelte, etc.)
- Specialized workflows (SEO, Jira, Flutter, etc.)
- Language-specific testing patterns
- Framework-specific deployment

**Structure:**
```
everything-claude-code/
├── skills/          # 185+ framework and language skills
├── commands/        # Framework-specific commands
└── rules/           # Language-specific rules
```

**Naming Convention:** Uses `SKILL.md` filename within category directories

**When to Use:**
- When working with specific frameworks not covered in main skills
- When framework-specific expertise is needed
- For language-specific patterns (C#, Dart, Flutter, etc.)
- When everything-claude-code workflows are being used

**Integration:**
- Standalone repository with its own workflows
- Can be referenced alongside EM-Skill
- Maintained separately

---

## Decision Matrix

| Scenario | Use This System | Why |
|----------|-----------------|-----|
| **New feature development** | Main `skills/` | EM-Skill primary skills |
| **Product requirement analysis** | Product-Manager-Skills | Business-focused skills |
| **Framework-specific work** | everything-claude-code | Specialized framework expertise |
| **Legacy agent-skills reference** | agent-skills (deprecated) | Backward compatibility |
| **CI/CD automation** | Main `skills/workflow/` | Git/CI/CD patterns |
| **Language-specific patterns** | everything-claude-code | Comprehensive language support |
| **Quality assurance** | Main `skills/quality/` | Code review, security, testing |

---

## Integration Patterns

### Pattern 1: EM-Skill Standard Workflow

```yaml
flow:
  1. Use "skills/foundation/spec-driven-development"
  2. Use "skills/development/test-driven-development"
  3. Use "agents/executor" to implement
  4. Use "skills/quality/code-review" for review
  5. Use "skills/workflow/git-workflow" for commits
```

### Pattern 2: Product-Focused Workflow

```yaml
flow:
  1. Use "Product-Manager-Skills/skills/user-story" for requirements
  2. Use "agents/product-manager" for validation
  3. Use main "skills/foundation/spec-driven-development" for technical spec
  4. Continue with EM-Skill standard workflow
```

### Pattern 3: Framework-Specific Workflow

```yaml
flow:
  1. Use "everything-claude-code/skills/[framework]-patterns" for framework expertise
  2. Use main "skills/development/test-driven-development" adapted for framework
  3. Use framework-specific testing from everything-claude-code
  4. Continue with EM-Skill quality gates
```

---

## Migration Guide

### From agent-skills to Main Skills

**Step 1: Identify Usage**
```bash
grep -r "agent-skills" /path/to/project
```

**Step 2: Find Equivalent**
```bash
# agent-skills/skills/tdd-workflow/SKILL.md
# → skills/development/test-driven-development.md
```

**Step 3: Update References**
```yaml
# Before
skills:
  - agent-skills/skills/tdd-workflow/SKILL.md

# After
skills:
  - skills/development/test-driven-development.md
```

**Step 4: Verify**
```bash
# Test that workflow still works
# Run quality gates
# Update documentation
```

---

## Best Practices

1. **Default to Main Skills** - Use main `skills/` unless specific need arises
2. **Product Manager for Business** - Use Product-Manager-Skills for business analysis
3. **Framework Experts** - Use everything-claude-code for framework-specific work
4. **Avoid Duplication** - Don't duplicate skills across systems
5. **Document Choices** - Document why a specific skill system was chosen
6. **Keep Skills Updated** - Regularly sync with upstream repositories

---

## Quick Reference

### Main Skills Categories

- **Foundation** (5 skills): spec-driven-development, brainstorming, context-engineering, writing-plans, systematic-debugging
- **Development** (8 skills): test-driven-development, frontend-patterns, backend-patterns, incremental-implementation, subagent-driven-development, source-driven-development, api-interface-design, security-hardening
- **Quality** (7 skills): code-review, code-simplification, browser-testing, performance-optimization, e2e-testing, security-audit, api-testing
- **Workflow** (5 skills): git-workflow, ci-cd-automation, documentation, finishing-branch, deprecation-migration

### Product Manager Skills Categories

- User Stories, Requirements, Prioritization, Strategy, Market Analysis, etc. (47 total skills)

### Everything Claude Code Categories

- 185+ skills across multiple languages and frameworks

---

## FAQ

**Q: Which skill system should I use by default?**
A: Use main `skills/` for all EM-Skill workflows.

**Q: When should I use Product-Manager-Skills?**
A: When Product Manager agent is involved or when business analysis is needed.

**Q: Is agent-skills still supported?**
A: It's deprecated. Migrate to main skills.

**Q: Can I mix skill systems in one workflow?**
A: Yes, but document the rationale and avoid duplication.

**Q: How do I know if a skill exists in main skills?**
A: Check `skills/` directory structure or use `find skills/ -name "*.md"`.

---

**Guide Version:** 1.0.0
**Last Updated:** 2026-04-19
**Maintained By:** EM-Skill Project
