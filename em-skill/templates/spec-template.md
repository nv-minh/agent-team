# Spec: [Project/Feature Name]

## Objective
[What we're building and why. User stories or acceptance criteria.]

### User Stories
- As a [user type], I want [feature] so that [benefit]
- As a [user type], I want [feature] so that [benefit]

### Success Criteria
- [Specific, measurable criteria that define success]
- [Each criterion should be testable]

## Tech Stack
[Framework, language, key dependencies with versions]

### Core Technologies
- [Technology 1]: [version] - [purpose]
- [Technology 2]: [version] - [purpose]

### External Dependencies
- [Dependency 1]: [version] - [purpose]
- [Dependency 2]: [version] - [purpose]

## Commands
[Build, test, lint, dev — full commands]

```bash
# Build
npm run build

# Test
npm test

# Test with coverage
npm test -- --coverage

# Lint
npm run lint --fix

# Dev server
npm run dev

# Type check
npx tsc --noEmit
```

## Project Structure
[Directory layout with descriptions]

```
src/                    # Application source code
├── components/         # React/Vue/Angular components
├── lib/               # Shared utilities and helpers
├── hooks/             # Custom hooks (if applicable)
├── services/          # API and business logic
├── types/             # TypeScript type definitions
└── index.ts           # Entry point

tests/                 # Unit and integration tests
├── unit/             # Unit tests
├── integration/      # Integration tests
└── fixtures/         # Test fixtures and data

e2e/                   # End-to-end tests
docs/                  # Documentation
```

## Code Style
[Example snippet + key conventions]

### Naming Conventions
- Files: [convention, e.g., kebab-case for components]
- Variables: [convention, e.g., camelCase]
- Constants: [convention, e.g., UPPER_SNAKE_CASE]
- Types/Interfaces: [convention, e.g., PascalCase]

### Code Organization
- [Pattern 1: description]
- [Pattern 2: description]

### Example Code
```typescript
// Example of preferred code style
export function createUser(data: UserData): User {
  const validated = validateUserData(data);
  return db.users.create(validated);
}
```

## Testing Strategy
[Framework, test locations, coverage requirements, test levels]

### Test Framework
- [Framework]: [version]
- [Assertion library]: [version]
- [Test runner]: [version]

### Test Structure
- Unit tests: [location and purpose]
- Integration tests: [location and purpose]
- E2E tests: [location and purpose]

### Coverage Requirements
- Minimum coverage: [percentage]
- Critical paths: [percentage]
- Threshold for CI: [percentage]

### Testing Guidelines
- [Guideline 1]
- [Guideline 2]

## Boundaries

### Always Do
- Run tests before commits
- Follow naming conventions
- Validate inputs
- Write tests for new code
- Review code before shipping
- Type check before committing

### Ask First
- Database schema changes
- Adding dependencies
- Changing CI config
- Breaking changes
- Performance optimizations
- Security-related changes

### Never Do
- Commit secrets (.env, API keys, passwords)
- Edit vendor directories
- Remove failing tests without approval
- Skip code review
- Push to main without tests
- Comment out code instead of removing it
- Disable linters or type checkers

## API Design (if applicable)

### Endpoints
- `GET /api/resource`: [description]
- `POST /api/resource`: [description]
- `PUT /api/resource/:id`: [description]
- `DELETE /api/resource/:id`: [description]

### Data Models
```typescript
interface Resource {
  id: string;
  // other fields
}
```

## Security Considerations
- [Security consideration 1]
- [Security consideration 2]
- [Authentication/Authorization approach]

## Performance Considerations
- [Performance consideration 1]
- [Performance consideration 2]
- [Target metrics]

## Open Questions
- [Question 1]
- [Question 2]

## Related Documentation
- [Link to related docs]
- [Link to API documentation]
- [Link to design docs]

## Changelog
- [Date]: [Initial spec creation]
