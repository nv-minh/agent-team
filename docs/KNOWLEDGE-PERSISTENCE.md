# Knowledge Persistence Feature

## Overview

The Knowledge Persistence feature allows EM-Team agents to learn project conventions and consistently apply them across all tasks. The Codebase-Mapper Agent extracts project-specific patterns and makes them available to all agents.

---

## How It Works

### 1. Knowledge Extraction

The Codebase-Mapper Agent analyzes your project and extracts:

**Naming Conventions:**
- File naming (kebab-case, camelCase, PascalCase)
- Function/variable naming conventions
- Class and constant naming patterns
- Private member conventions

**Code Style:**
- Indentation (spaces/tabs, size)
- Line length limits
- Quote style (single/double)
- Semicolon usage
- Comment patterns

**Architectural Patterns:**
- Overall architecture (layered, hexagonal, microservices)
- Common design patterns used
- Dependency injection approaches
- State management patterns

**Testing Conventions:**
- Test structure and organization
- Test naming conventions
- Coverage requirements
- Test helper patterns

**Git Conventions:**
- Commit message format
- Branch naming patterns
- PR guidelines

### 2. Knowledge Storage

Extracted knowledge is stored in `.claude/knowledge/`:

```
.claude/knowledge/
├── README.md                    # Knowledge base documentation
├── project-conventions.md       # All project conventions
├── coding-style.md              # Code style guide
├── architecture-patterns.md     # Architectural patterns
├── dependencies.md              # Dependency mapping
└── examples/                    # Representative code samples
    ├── component-example.tsx
    ├── service-example.ts
    └── test-example.test.ts
```

### 3. Agent Consumption

When any agent starts a task, it automatically:

1. **Loads Knowledge:**
   - Reads `project-conventions.md`
   - Loads relevant code examples
   - Understands architecture patterns

2. **Applies Knowledge:**
   - Follows naming conventions
   - Matches code style
   - Uses existing patterns
   - Maintains consistency

3. **Validates Output:**
   - Checks against conventions
   - Ensures consistency
   - Validates patterns match

---

## Usage

### Initial Knowledge Extraction

```bash
# Extract and persist project knowledge
Agent: codebase-mapper - Analyze this project and save conventions
```

The agent will:
1. Scan your project structure
2. Analyze code patterns
3. Extract conventions
4. Save to `.claude/knowledge/`
5. Provide summary report

### View Knowledge Base

```bash
# View all conventions
cat .claude/knowledge/project-conventions.md

# View code style guide
cat .claude/knowledge/coding-style.md

# View architecture patterns
cat .claude/knowledge/architecture-patterns.md

# List knowledge files
ls -la .claude/knowledge/
```

### Update Knowledge

Update knowledge when:
- After major refactoring
- When coding conventions change
- Before starting large features
- When style drift is detected

```bash
# Update knowledge base
Agent: codebase-mapper - Update knowledge base
```

### Agents Using Knowledge

All agents automatically use knowledge:

```bash
# Frontend Expert - automatically follows component conventions
Agent: frontend-expert - Create user profile component

# Backend Expert - automatically follows service patterns
Agent: backend-expert - Create user authentication service

# Planner - automatically plans with conventions
Agent: planner - Create plan for payment feature

# Executor - automatically implements with project style
Agent: executor - Implement user management
```

---

## Example Knowledge File

**File:** `.claude/knowledge/project-conventions.md`

```markdown
# Project Conventions Knowledge Base

**Project:** MyProject
**Last Updated:** 2026-04-19
**Extracted By:** Codebase-Mapper Agent

## Naming Conventions

### Files
- Components: PascalCase (e.g., `UserProfile.tsx`)
- Utilities: camelCase (e.g., `formatDate.ts`)
- Tests: Same name with `.test.` suffix (e.g., `UserProfile.test.tsx`)

### Code
- Variables/Functions: camelCase (e.g., `getUserData`)
- Classes/Interfaces: PascalCase (e.g., `UserService`)
- Constants: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

## Code Style

### Formatting
- Indentation: 2 spaces
- Max line length: 100 characters
- Semicolons: Required
- Quotes: Single quotes

### Patterns
- Functional components with hooks only
- Named exports preferred over default
- Async/await for promises

## Architecture Patterns

### Detected Pattern
**Primary:** Layered Architecture
**Secondary:** Feature-based organization

### Common Patterns Used
- Repository Pattern for data access
- Factory Pattern for component creation
- Observer Pattern for state management

## Testing Conventions

### Test Structure
```typescript
describe('ComponentName', () => {
  it('should do something', () => {
    // Arrange
    // Act
    // Assert
  });
});
```

## Git Conventions

### Commit Message Format
```
type(scope): description

Examples:
feat(auth): add JWT authentication
fix(api): resolve race condition
```
```

---

## Benefits

### For Developers
- **Consistency:** All agents follow the same conventions
- **Quality:** Code style matches project patterns
- **Speed:** Less manual correction of agent output
- **Onboarding:** New team members see project patterns

### For Agents
- **Context:** Agents understand project conventions
- **Accuracy:** Output matches project style
- **Integration:** Fits seamlessly with existing code
- **Learning:** Builds knowledge over time

### For Projects
- **Maintainability:** Consistent code across all agent work
- **Quality:** All code follows established patterns
- **Documentation:** Conventions are documented automatically
- **Evolution:** Knowledge grows with the project

---

## Best Practices

### 1. Initial Setup
Run knowledge extraction on existing projects before agent work:
```bash
Agent: codebase-mapper - Analyze project and save conventions
```

### 2. Regular Updates
Update knowledge after significant changes:
- Major refactoring
- New architecture patterns
- Changed coding standards
- New dependencies

### 3. Review Knowledge
Review extracted knowledge for accuracy:
```bash
cat .claude/knowledge/project-conventions.md
```

Edit if needed to correct or add conventions.

### 4. Team Alignment
Share knowledge with team:
- Commit `.claude/knowledge/` to version control
- Reference in onboarding documentation
- Update when team agreements change

### 5. Monitor Compliance
Check if agents are following conventions:
- Review agent-generated code
- Look for style drift
- Update knowledge if patterns change

---

## Technical Details

### Knowledge Extraction Algorithm

```python
def extract_knowledge(project):
    knowledge = {
        'naming_conventions': analyze_naming_patterns(project),
        'code_style': analyze_style_patterns(project),
        'architecture': detect_architecture(project),
        'testing': analyze_testing_patterns(project),
        'git': analyze_git_history(project),
        'examples': collect_representative_samples(project)
    }
    return format_knowledge(knowledge)
```

### Agent Loading Mechanism

```yaml
agent_task_flow:
  1. check_knowledge_exists:
     - if .claude/knowledge/ exists
       - load project-conventions.md
       - load relevant examples
     - else
       - warn about missing knowledge

  2. apply_knowledge:
     - for each convention
       - apply to code generation
       - validate against examples
       - ensure consistency

  3. verify_output:
     - check against conventions
     - validate style matches
     - confirm patterns aligned
```

### Knowledge Update Strategy

```bash
# Full extraction (overwrites existing)
Agent: codebase-mapper - Extract all project knowledge

# Incremental update (merges with existing)
Agent: codebase-mapper - Update knowledge with new patterns

# Specific area update
Agent: codebase-mapper - Update testing conventions only
```

---

## Troubleshooting

### Issue: Knowledge Not Loaded

**Symptom:** Agents don't follow project conventions

**Solutions:**
1. Check knowledge exists: `ls -la .claude/knowledge/`
2. Verify format: `cat .claude/knowledge/project-conventions.md`
3. Re-extract: `Agent: codebase-mapper - Re-extract knowledge`

### Issue: Incorrect Conventions

**Symptom:** Knowledge doesn't match actual project

**Solutions:**
1. Manually edit: `vim .claude/knowledge/project-conventions.md`
2. Re-extract with focus: `Agent: codebase-mapper - Focus on specific area`
3. Report issue if extraction is wrong

### Issue: Agents Ignore Knowledge

**Symptom:** Agents don't apply conventions

**Solutions:**
1. Check agent has knowledge access
2. Verify knowledge is in correct location
3. Restart agent session
4. Check knowledge format is valid

---

## Future Enhancements

Planned improvements:

- [ ] Automatic knowledge updates when conventions change
- [ ] Knowledge versioning and diff tracking
- [ ] Convention conflict detection
- [ ] Knowledge quality scoring
- [ ] Multi-project knowledge support
- [ ] Knowledge sharing between projects
- [ ] Convention compliance reporting
- [ ] AI-powered convention suggestion

---

## Documentation

- **Agent Documentation:** `agents/codebase-mapper.md`
- **Knowledge Base:** `.claude/knowledge/README.md`
- **Conventions:** `.claude/knowledge/project-conventions.md`

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Feature:** Knowledge Persistence for EM-Team v1.2.0
