---
name: test-generation
description: "Auto-generate test cases from source code, specs, and user stories. Use when you need test cases created from existing code, requirements documents, or user stories."
version: "1.0.0"
category: "quality"
origin: "em-team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["generate tests", "auto generate tests", "create test cases", "test generation", "test case template"]
intent: "Analyze source code and specifications to auto-generate comprehensive test cases covering unit, integration, and E2E levels with structured templates."
scenarios:
  - "Analyzing a service module and generating unit tests for every public method with edge cases"
  - "Reading API route definitions and generating integration tests with request/response contracts"
  - "Converting user stories into E2E test scenarios with step-by-step procedures"
best_for: "auto-generating tests, code-to-test conversion, spec-to-test conversion, test case templates"
estimated_time: "15-45 min"
anti_patterns:
  - "Generating tests without analyzing the actual code implementation and its branches"
  - "Creating only happy-path tests and ignoring error paths, edge cases, and boundary conditions"
  - "Generating tests that duplicate the implementation logic instead of testing behavior"
related_skills: ["test-driven-development", "api-testing", "browser-testing", "e2e-testing"]
---

# Test Generation

## Overview

Auto-generate test cases from source code, specifications, and user stories. This skill analyzes code to identify testable units, maps all conditional branches, and produces structured test cases with clear input/output expectations.

## When to Use

- Need test cases generated from existing source code
- Converting specifications or user stories into test scenarios
- Building comprehensive test coverage for a new module
- Creating structured test documentation for QA handoff

## Structured Test Case Template

Every generated test case follows this structure:

| Field | Description | Example |
|---|---|---|
| **TC-ID** | Unique identifier | TC-UNIT-001, TC-INT-001, TC-E2E-001 |
| **Title** | Descriptive test case name | "Create user with valid data" |
| **Type** | Test level | unit / integration / e2e |
| **Preconditions** | What must be true before execution | "Database is empty, no users exist" |
| **Input** | Structured input data | `{ name: "John", email: "john@test.com" }` |
| **Steps** | Ordered sequence of actions | "1. Call createUser() with input data" |
| **Expected Output** | Exact expected result | `{ status: 201, body: { id: "..." } }` |
| **Actual Output** | Filled during execution | (initially empty) |
| **Pass/Fail** | Determined by comparing expected vs actual | PASS / FAIL |
| **Priority** | Importance level | critical / high / medium / low |
| **Tags** | Categorization labels | auth, registration, happy-path |

### Test Case ID Convention

```
TC-{LEVEL}-{NNN}

Levels:
  UNIT  — Unit tests (isolated functions/methods)
  INT   — Integration tests (component interactions)
  E2E   — End-to-end tests (full user workflows)
  PERF  — Performance tests (timing/load)
```

## Generation Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  1. ANALYZE ──→ 2. MAP BRANCHES ──→ 3. GENERATE CASES           │
│     Source code     Conditional paths     Apply template          │
│                                                                  │
│  4. WRITE TESTS ──→ 5. VALIDATE                                 │
│     Generate code     Run + verify coverage                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Step 1: ANALYZE

Read source files and identify the testable surface:

```typescript
// For each source file, identify:
// 1. Exported functions/methods
// 2. Function signatures (parameters, return types)
// 3. Class constructors and public API
// 4. API route handlers (method, path, middleware)
// 5. React component props and events
// 6. State transitions and side effects
```

**Analysis checklist:**
- [ ] All exported functions identified
- [ ] Parameter types and constraints documented
- [ ] Return types and possible error values mapped
- [ ] Dependencies and side effects listed
- [ ] External API calls and I/O operations noted

### Step 2: MAP BRANCHES

Trace every conditional path through the code:

```typescript
// Given this function:
function divide(a: number, b: number): number {
  if (b === 0) throw new Error('Division by zero');
  if (!Number.isFinite(a) || !Number.isFinite(b)) {
    throw new Error('Inputs must be finite numbers');
  }
  return a / b;
}

// Branches to test:
// Path 1: b === 0           → throws "Division by zero"
// Path 2: a is not finite   → throws "Inputs must be finite numbers"
// Path 3: b is not finite   → throws "Inputs must be finite numbers"
// Path 4: both valid        → returns a / b
```

### Step 3: GENERATE CASES

Apply the test case template for each identified branch:

```yaml
# TC-UNIT-001
title: "divide() returns quotient for valid inputs"
type: unit
preconditions: "None"
input:
  a: 10
  b: 2
steps:
  - "Call divide(10, 2)"
expected_output:
  return_value: 5
  throws: false
actual_output: {}
pass_fail: "NOT_RUN"
priority: critical
tags: [happy-path, math]

# TC-UNIT-002
title: "divide() throws on division by zero"
type: unit
preconditions: "None"
input:
  a: 10
  b: 0
steps:
  - "Call divide(10, 0)"
expected_output:
  throws: true
  error_message: "Division by zero"
actual_output: {}
pass_fail: "NOT_RUN"
priority: critical
tags: [error-path, edge-case]
```

### Step 4: WRITE TESTS

Generate actual test code from the templates:

```typescript
// Generated from TC-UNIT-001 and TC-UNIT-002
describe('divide', () => {
  it('should return quotient for valid inputs', () => {
    expect(divide(10, 2)).toBe(5);
  });

  it('should throw on division by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero');
  });

  it('should throw for non-finite numerator', () => {
    expect(() => divide(Infinity, 2)).toThrow('Inputs must be finite numbers');
  });

  it('should throw for non-finite denominator', () => {
    expect(() => divide(10, NaN)).toThrow('Inputs must be finite numbers');
  });
});
```

### Step 5: VALIDATE

Run generated tests and verify coverage:

```bash
# Run tests and collect coverage
npm test -- --coverage

# Verify all branches covered
# Target: 100% branch coverage for analyzed functions
```

## Code Analysis Patterns

### Analyzing Functions

```typescript
// Source: calculateDiscount(price, tier, isFirstPurchase)
//
// Analysis:
// - Parameters: price (number, must be > 0), tier ('basic'|'premium'|'vip'), isFirstPurchase (boolean)
// - Returns: number (discounted price)
// - Branches: 3 tier values × 2 isFirstPurchase values = 6 paths minimum
// - Edge cases: price = 0, negative price, unknown tier
//
// Generated test cases:
// TC-UNIT-001: basic tier, not first purchase → 0% discount
// TC-UNIT-002: basic tier, first purchase → 10% discount
// TC-UNIT-003: premium tier, not first purchase → 15% discount
// TC-UNIT-004: premium tier, first purchase → 25% discount
// TC-UNIT-005: vip tier, not first purchase → 30% discount
// TC-UNIT-006: vip tier, first purchase → 40% discount
// TC-UNIT-007: price = 0 → throws or returns 0
// TC-UNIT-008: negative price → throws
// TC-UNIT-009: unknown tier → throws or default
```

### Analyzing API Routes

```typescript
// Source: POST /api/users
// Route handler: createUser(req, res)
// Middleware: validateBody(userSchema), authenticate
//
// Analysis:
// - Required fields: name (string, 2-100 chars), email (valid email), password (8+ chars, 1 uppercase, 1 number)
// - Auth: Bearer token required
// - Status codes: 201 (created), 400 (validation), 401 (unauthorized), 409 (duplicate email), 500 (server error)
//
// Generated test cases:
// TC-INT-001: Valid data + valid token → 201 + user object
// TC-INT-002: Missing name → 400 + validation error
// TC-INT-003: Invalid email → 400 + validation error
// TC-INT-004: Weak password → 400 + validation error
// TC-INT-005: Duplicate email → 409 + conflict error
// TC-INT-006: No auth token → 401 + unauthorized error
// TC-INT-007: Invalid auth token → 401 + unauthorized error
// TC-INT-008: Server error → 500 + error response
```

### Analyzing React Components

```typescript
// Source: <UserCard user={user} onEdit={handler} onDelete={handler} />
// Props: user (User), onEdit (callback), onDelete (callback)
// State: isConfirmingDelete (boolean)
// Renders: name, email, edit button, delete button, confirm dialog
//
// Generated test cases:
// TC-UNIT-001: Renders user name and email
// TC-UNIT-002: Click edit button → calls onEdit with user
// TC-UNIT-003: Click delete → shows confirm dialog
// TC-UNIT-004: Confirm delete → calls onDelete with user.id
// TC-UNIT-005: Cancel delete → hides confirm dialog
// TC-UNIT-006: Missing user prop → graceful fallback
```

## Generating Unit Tests from Source Code

```typescript
// Template: Unit test for a service function
// Replace {{placeholders}} with analysis results

describe('{{FunctionName}}', () => {
  // {{TC-UNIT-XXX}}: Happy path
  it('should {{expected_behavior}} when {{condition}}', async () => {
    // Arrange
    const input = {{valid_input}};
    {{setup_mocks}}

    // Act
    const result = await {{function_call}};

    // Assert
    expect(result).{{matcher}}({{expected_value}});
  });

  // {{TC-UNIT-XXX}}: Error path
  it('should throw {{error_type}} when {{error_condition}}', async () => {
    // Arrange
    const input = {{invalid_input}};

    // Act & Assert
    await expect({{function_call}})
      .rejects
      .toThrow('{{error_message}}');
  });

  // {{TC-UNIT-XXX}}: Edge case
  it('should handle {{edge_case}}', async () => {
    const input = {{edge_input}};
    const result = await {{function_call}};
    expect(result).{{matcher}}({{expected_edge_result}});
  });
});
```

## Generating Integration Tests from API Specs

```typescript
// Template: Integration test for an API endpoint
// Uses the APIContract structure from api-testing skill

import request from 'supertest';
import { app } from '../app';

describe('{{Endpoint}} {{Method}} {{Path}}', () => {
  // {{TC-INT-XXX}}: Success case
  it('should return {{status}} with valid input', async () => {
    const response = await request(app)
      .{{method}}('{{path}}')
      .set('Authorization', `Bearer ${token}`)
      .send({{valid_body}})
      .expect({{expected_status}});

    expect(response.body).toMatchObject({{expected_body_shape}});
    expect(response.body.data).not.toHaveProperty('{{sensitive_field}}');
  });

  // {{TC-INT-XXX}}: Validation error
  it('should return 400 with invalid input', async () => {
    const response = await request(app)
      .{{method}}('{{path}}')
      .send({{invalid_body}})
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  // {{TC-INT-XXX}}: Auth failure
  it('should return 401 without authentication', async () => {
    await request(app)
      .{{method}}('{{path}}')
      .send({{valid_body}})
      .expect(401);
  });
});
```

## Generating E2E Tests from User Stories

### User Story → Test Scenario Conversion

```
User Story: "As a registered user, I want to reset my password so that I can regain access"

↓ Converted to E2E test scenario ↓

TC-E2E-001: Password Reset Flow
  Preconditions:
    - User account exists with email "user@test.com"
    - User is logged out
    - Email service is mocked
  Steps:
    1. Navigate to /login
    2. Click "Forgot password?" link
    3. Enter email "user@test.com"
    4. Click "Send reset link"
    5. Verify success message shown
    6. Extract reset token from mocked email
    7. Navigate to /reset-password?token={token}
    8. Enter new password "NewPass123!"
    9. Confirm new password "NewPass123!"
    10. Click "Reset password"
  Expected Output:
    - Redirected to /login
    - Flash message "Password reset successfully"
    - Can login with new password
  Priority: critical
  Tags: [auth, password-reset, critical-path]
```

### Playwright E2E Template

```typescript
// Template: E2E test from user story
import { test, expect } from '@playwright/test';

test.describe('{{Feature Name}}', () => {
  // {{TC-E2E-XXX}}: {{User story summary}}
  test('should {{user_story_action}}', async ({ page }) => {
    // Precondition setup
    {{precondition_setup}}

    // Step 1-N: Execute user actions
    {{step_actions}}

    // Verify expected outcome
    {{verify_expectations}}
  });
});
```

## Edge Case Discovery

Systematically discover edge cases from code analysis:

### Input Edge Cases

| Category | Pattern | Example |
|---|---|---|
| **Null/Undefined** | Function receives null or undefined | `processUser(null)` |
| **Empty** | Empty string, array, or object | `searchUsers("")` |
| **Boundary** | Min/max values, off-by-one | Age: 17, 18, 19 for minimum 18 |
| **Type Mismatch** | Wrong type passed | `{ age: "twenty" }` instead of number |
| **Special Chars** | Unicode, SQL injection, XSS | `name: "<script>alert(1)</script>"` |
| **Oversized** | Strings/arrays beyond max length | `name: "a".repeat(10000)` |
| **Whitespace** | Whitespace-only or trimmed input | `name: "   "` |

### State Edge Cases

| Category | Pattern | Example |
|---|---|---|
| **Empty State** | No data exists yet | Get users when DB is empty |
| **Duplicate** | Unique constraint violation | Create user with existing email |
| **Concurrent** | Race conditions | Two users booking same seat |
| **Expired** | Token/session expiration | Reset password with expired token |
| **Permission** | Unauthorized access | Regular user accessing admin API |

### Error Propagation

| Category | Pattern | Example |
|---|---|---|
| **Network** | External API timeout | Payment gateway timeout |
| **Database** | Connection lost mid-transaction | DB error during user creation |
| **File System** | File not found | Missing upload directory |
| **Validation** | Multi-field validation | Multiple fields failing simultaneously |

## Test Code Templates

### Unit Test — Function

```typescript
describe('{{FunctionName}}', () => {
  // Happy path
  it('should return {{expected}} for {{input_desc}}', () => {
    expect({{functionName}}({{input}})).toBe({{expected}});
  });

  // Error path
  it('should throw for {{error_desc}}', () => {
    expect(() => {{functionName}}({{bad_input}})).toThrow('{{error}}');
  });

  // Edge cases
  it.each([
    { input: {{edge1}}, expected: {{result1}}, desc: '{{desc1}}' },
    { input: {{edge2}}, expected: {{result2}}, desc: '{{desc2}}' },
  ])('should handle $desc', ({ input, expected }) => {
    expect({{functionName}}(input)).toBe(expected);
  });
});
```

### Unit Test — Class Method

```typescript
describe('{{ClassName}}.{{MethodName}}', () => {
  let instance: {{ClassName}};

  beforeEach(() => {
    instance = new {{ClassName}}({{constructor_args}});
  });

  it('should {{behavior}} when {{condition}}', async () => {
    const result = await instance.{{methodName}}({{input}});
    expect(result).{{matcher}}({{expected}});
  });

  afterEach(() => {
    {{cleanup}}
  });
});
```

### Integration Test — API Endpoint

```typescript
describe('{{Method}} {{Path}}', () => {
  it('should return {{status}} {{when}}', async () => {
    const response = await request(app)
      .{{method}}('{{path}}')
      .set('Authorization', `Bearer ${token}`)
      .send({{body}});

    expect(response.status).toBe({{status}});
    expect(response.body).toMatchObject({{expected_body}});
  });
});
```

### E2E Test — User Flow

```typescript
test.describe('{{Feature}}', () => {
  test('should {{user_story}}', async ({ page }) => {
    await page.goto('{{start_url}}');
    {{actions}}
    await expect(page.locator('{{selector}}')).{{matcher}}({{expected}});
  });
});
```

### Performance Test — API Timing

```typescript
describe('Performance: {{Method}} {{Path}}', () => {
  const THRESHOLD_P95 = {{threshold_ms}};
  const SAMPLES = {{sample_count}};
  const times: number[] = [];

  for (let i = 0; i < SAMPLES; i++) {
    it(`sample ${i + 1}`, async () => {
      const start = performance.now();
      await request(app).{{method}}('{{path}}').expect({{status}});
      times.push(performance.now() - start);
    });
  }

  afterAll(() => {
    times.sort((a, b) => a - b);
    const p95 = times[Math.floor(SAMPLES * 0.95)];
    expect(p95).toBeLessThan(THRESHOLD_P95);
  });
});
```

## Coaching Notes

> **ABC - Always Be Coaching:** Generated tests are a starting point, not a finish line. Review every generated test case — the AI can spot branches you missed, but it cannot judge business importance like you can.

1. **Analyze Before Generating:** The quality of generated tests is proportional to the quality of code analysis. Read the code thoroughly, understand the business domain, then generate. Garbage in, garbage out.
2. **Template Is a Contract:** The test case template (TC-ID, Input, Expected Output, Actual Output, Pass/Fail) is a contract between developer and QA. Fill every field completely — incomplete test cases are worse than no test cases because they create false confidence.
3. **Edge Cases Are Where Bugs Live:** Most production incidents come from untested edge cases, not untested happy paths. Spend 70% of generation effort on error paths, boundary conditions, and unusual inputs.

## Verification

After test generation:

- [ ] All exported functions/methods have corresponding test cases
- [ ] Test case template fully filled (TC-ID through Tags)
- [ ] Every conditional branch has at least one test case
- [ ] Edge cases systematically covered (null, empty, boundary, type, special chars)
- [ ] Error paths have explicit test cases (not just "should throw")
- [ ] Generated test code compiles and runs
- [ ] Coverage targets met for analyzed functions
- [ ] Test cases are independent and can run in any order
