---
name: test-driven-development
description: Test-Driven Development (TDD) using RED-GREEN-REFACTOR cycle. Use when writing any production code, adding new features, or fixing bugs.
---

# Test-Driven Development

## Overview

Test-Driven Development (TDD) is a development process where you write tests before writing production code. The TDD cycle (RED-GREEN-REFACTOR) ensures that code is tested, maintainable, and meets requirements.

## The Iron Law

**NO PRODUCTION CODE WITHOUT FAILING TEST**

Never write production code without first writing a failing test that justifies its existence. This is the foundation of TDD.

## When to Use

- Writing any new feature or functionality
- Fixing bugs (write regression test first)
- Refactoring existing code
- Adding new methods or functions
- Modifying existing behavior

**When NOT to use:** Configuration files, documentation, or simple data structures that don't contain logic.

## The TDD Cycle: RED-GREEN-REFACTOR

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│    RED ──→ GREEN ──→ REFACTOR ──→ (repeat)            │
│      ↓         ↓           ↓                           │
│   Write      Make         Clean                        │
│  failing   it pass    up code                         │
│    test                                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Phase 1: RED - Write a Failing Test

Write a test that fails because the functionality doesn't exist yet.

**Guidelines:**
- Write the **minimum** test needed to drive new functionality
- Test **behavior**, not implementation details
- Use **descriptive** test names that explain what is being tested
- Run the test and confirm it fails with the expected error

**Example:**
```typescript
// RED: Write failing test
describe('UserService', () => {
  it('should create a new user with valid data', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com'
    };

    const user = await createUser(userData);

    expect(user).toBeDefined();
    expect(user.id).toBeDefined();
    expect(user.name).toBe('John Doe');
    expect(user.email).toBe('john@example.com');
  });
});
```

**Run and confirm failure:**
```bash
npm test -- --grep "should create a new user"
# Expected: FAIL - "createUser is not defined"
```

### Phase 2: GREEN - Make the Test Pass

Write the **minimum** production code needed to make the test pass.

**Guidelines:**
- Write the **simplest** code that makes the test pass
- Don't worry about code quality yet (that comes in refactoring)
- Hardcode values if needed (you'll generalize in refactor)
- Run the test frequently to see it pass

**Example:**
```typescript
// GREEN: Write minimal implementation
export async function createUser(userData: UserData): Promise<User> {
  return {
    id: '1',
    name: userData.name,
    email: userData.email
  };
}
```

**Run and confirm success:**
```bash
npm test -- --grep "should create a new user"
# Expected: PASS
```

### Phase 3: REFACTOR - Clean Up the Code

Improve the code structure and quality while keeping tests green.

**Guidelines:**
- Remove duplication
- Extract magic values to named constants
- Improve names and structure
- **Keep tests green** throughout refactoring
- Run tests after each small refactoring

**Example:**
```typescript
// REFACTOR: Improve code quality
const generateId = (): string => crypto.randomUUID();

export async function createUser(userData: UserData): Promise<User> {
  const user: User = {
    id: generateId(),
    name: userData.name,
    email: userData.email
  };

  return user;
}
```

**Run and confirm still passing:**
```bash
npm test -- --grep "should create a new user"
# Expected: PASS (still green after refactoring)
```

## Test Organization

### Test Structure (AAA Pattern)

Organize tests using Arrange-Act-Assert pattern:

```typescript
it('should calculate total with tax', () => {
  // Arrange: Set up the test data
  const price = 100;
  const taxRate = 0.1;

  // Act: Execute the function being tested
  const total = calculateTotal(price, taxRate);

  // Assert: Verify the result
  expect(total).toBe(110);
});
```

### Test Descriptions

Write test descriptions that answer:
1. What is being tested?
2. Under what conditions?
3. What is the expected outcome?

```
✅ Good: "should return 404 when user not found"
✅ Good: "should validate email format"
❌ Bad: "test 1"
❌ Bad: "it works"
```

### Test Files Organization

```
src/
├── services/
│   └── userService.ts
└── services.test.ts          # Co-located tests

OR

tests/
└── unit/
    └── services/
        └── userService.test.ts  # Separate test directory
```

## Testing Best Practices

### DO ✅

- Test behavior, not implementation
- Write descriptive test names
- Use AAA (Arrange-Act-Assert) pattern
- Test edge cases and error conditions
- Keep tests independent and isolated
- Use test doubles (mocks, stubs) appropriately
- Keep tests fast and focused

### DON'T ❌

- Test implementation details
- Write brittle tests that break on refactoring
- Test multiple things in one test
- Duplicate implementation logic in tests
- Over-mock (tests become tests of mocks)
- Write tests that are too complex

## Test Coverage

### Coverage Goals

- **Critical paths:** 100% coverage
- **Business logic:** 90%+ coverage
- **Utilities/helpers:** 95%+ coverage
- **Configuration:** 50%+ coverage

### Coverage Types

1. **Line Coverage:** Percentage of code lines executed
2. **Branch Coverage:** Percentage of conditional branches taken
3. **Function Coverage:** Percentage of functions called
4. **Statement Coverage:** Percentage of statements executed

### Coverage Tools

```bash
# Generate coverage report
npm test -- --coverage

# View coverage in browser
open coverage/lcov-report/index.html
```

## Testing Patterns

### Parameterized Tests

Test multiple scenarios with one test:

```typescript
describe('calculateDiscount', () => {
  const cases = [
    { amount: 100, discount: 0.1, expected: 90 },
    { amount: 100, discount: 0.2, expected: 80 },
    { amount: 100, discount: 0.5, expected: 50 }
  ];

  test.each(cases)(
    'should calculate discount for amount $amount with discount $discount',
    ({ amount, discount, expected }) => {
      expect(calculateDiscount(amount, discount)).toBe(expected);
    }
  );
});
```

### Async Tests

Handle asynchronous code properly:

```typescript
it('should fetch user data', async () => {
  const user = await fetchUser('1');

  expect(user).toBeDefined();
  expect(user.id).toBe('1');
});
```

### Error Testing

Test error conditions:

```typescript
it('should throw error for invalid input', () => {
  expect(() => {
    calculateTotal(-100, 0.1);
  }).toThrow('Amount must be positive');
});
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write tests later" | Tests written later are rarely written. Write them first. |
| "This is too simple to test" | Simple code breaks too. Tests prevent regressions. |
| "Tests take too long" | Tests save debugging time. They're an investment, not a cost. |
| "I know this works" | You might know it works now. Will you know in 6 months? |

## Red Flags

- Writing code without a failing test
- Tests that are too complex to understand
- Tests that test implementation details
- Skipping tests to save time
- Tests that are always green (false positives)
- Tests that are flaky (unreliable)

## Verification

After completing TDD cycle:

- [ ] Test written first (RED phase)
- [ ] Minimal code written to pass (GREEN phase)
- [ ] Code refactored while keeping tests green (REFACTOR phase)
- [ ] All tests pass
- [ ] Code is clean and follows conventions
- [ ] No duplication or code smells
- [ ] Coverage meets requirements
