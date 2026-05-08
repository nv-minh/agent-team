---
name: api-testing
description: API testing for integration, contract verification, and performance benchmarking. Use when testing API endpoints, verifying integrations, ensuring API contracts, or benchmarking response times.
version: "3.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["api test", "endpoint test", "contract test", "integration test", "api contract", "response time", "api performance", "api benchmark"]
intent: "Verify that APIs behave correctly under all conditions by testing contracts, error handling, authentication boundaries, and response time SLAs."
scenarios:
  - "Writing contract tests for a new REST endpoint before frontend integration begins"
  - "Testing authentication and authorization on protected admin API routes"
  - "Validating rate limiting and error response schemas across the user service API"
  - "Benchmarking API endpoint response times against SLA thresholds"
  - "Running a structured contract test validating input, expected output, actual output, and timing"
best_for: "endpoint testing, contract validation, auth testing, error handling verification, rate limiting tests, API performance testing, response time validation, contract benchmarks"
estimated_time: "15-30 min"
anti_patterns:
  - "Testing only the happy path and ignoring error responses and edge cases"
  - "Letting tests depend on execution order or shared mutable state"
  - "Hardcoding test data that causes conflicts when tests run in parallel"
related_skills: ["e2e-testing", "security-audit", "api-interface-design", "performance-optimization", "test-generation"]
---

# API Testing

## Overview

API testing verifies that APIs work correctly, handle errors properly, and meet their contracts. API tests are faster than E2E tests and catch integration issues that unit tests miss.

## When to Use

- Testing API endpoints
- Verifying integrations
- Ensuring API contracts
- Testing error handling
- Validating data formats

## Testing Strategy

### Test Pyramid for APIs

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    E2E Tests (10%)                     │
│                  ────────────────                      │
│                  Critical workflows                    │
│                                                         │
│              API Tests (40%)                           │
│              ────────────────                          │
│              Endpoints & contracts                     │
│                                                         │
│              Unit Tests (50%)                          │
│              ─────────────                             │
│              Individual functions                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## API Test Structure

### Using Supertest

```typescript
// ✅ Good: API test with Supertest
import request from 'supertest';
import { app } from '../app';

describe('User API', () => {
  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'SecurePass123!'
      };

      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      expect(response.body).toMatchObject({
        success: true,
        data: {
          id: expect.any(String),
          name: userData.name,
          email: userData.email
        }
      });

      expect(response.body.data).not.toHaveProperty('password');
    });

    it('should return 400 for invalid data', async () => {
      const invalidData = {
        name: 'J',
        email: 'not-an-email',
        password: 'weak'
      };

      const response = await request(app)
        .post('/api/users')
        .send(invalidData)
        .expect(400);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: expect.any(String)
        }
      });
    });

    it('should return 409 for duplicate email', async () => {
      const userData = {
        name: 'Jane Doe',
        email: 'existing@example.com',
        password: 'SecurePass123!'
      };

      // First request should succeed
      await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      // Second request should fail
      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(409);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          code: 'CONFLICT',
          message: 'User already exists'
        }
      });
    });
  });
});
```

## Test Scenarios

### 1. CRUD Operations

```typescript
describe('Todo API', () => {
  let todoId: string;

  describe('POST /api/todos', () => {
    it('should create a new todo', async () => {
      const todoData = {
        title: 'Test Todo',
        description: 'Test Description'
      };

      const response = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${token}`)
        .send(todoData)
        .expect(201);

      expect(response.body.data).toMatchObject({
        id: expect.any(String),
        title: todoData.title,
        description: todoData.description,
        completed: false
      });

      todoId = response.body.data.id;
    });
  });

  describe('GET /api/todos/:id', () => {
    it('should get a todo by id', async () => {
      const response = await request(app)
        .get(`/api/todos/${todoId}`)
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body.data).toMatchObject({
        id: todoId,
        title: 'Test Todo'
      });
    });

    it('should return 404 for non-existent todo', async () => {
      const response = await request(app)
        .get('/api/todos/non-existent')
        .set('Authorization', `Bearer ${token}`)
        .expect(404);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          code: 'NOT_FOUND'
        }
      });
    });
  });

  describe('PATCH /api/todos/:id', () => {
    it('should update a todo', async () => {
      const updateData = {
        title: 'Updated Todo',
        completed: true
      };

      const response = await request(app)
        .patch(`/api/todos/${todoId}`)
        .set('Authorization', `Bearer ${token}`)
        .send(updateData)
        .expect(200);

      expect(response.body.data).toMatchObject({
        id: todoId,
        title: 'Updated Todo',
        completed: true
      });
    });
  });

  describe('DELETE /api/todos/:id', () => {
    it('should delete a todo', async () => {
      await request(app)
        .delete(`/api/todos/${todoId}`)
        .set('Authorization', `Bearer ${token}`)
        .expect(204);

      // Verify it's deleted
      await request(app)
        .get(`/api/todos/${todoId}`)
        .set('Authorization', `Bearer ${token}`)
        .expect(404);
    });
  });
});
```

### 2. Authentication & Authorization

```typescript
describe('Auth Middleware', () => {
  it('should allow access with valid token', async () => {
    const response = await request(app)
      .get('/api/users/me')
      .set('Authorization', `Bearer ${validToken}`)
      .expect(200);

    expect(response.body.data).toHaveProperty('id');
  });

  it('should deny access without token', async () => {
    const response = await request(app)
      .get('/api/users/me')
      .expect(401);

    expect(response.body).toMatchObject({
      success: false,
      error: {
        code: 'UNAUTHORIZED'
      }
    });
  });

  it('should deny access with invalid token', async () => {
    const response = await request(app)
      .get('/api/users/me')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);

    expect(response.body).toMatchObject({
      success: false,
      error: {
        code: 'UNAUTHORIZED'
      }
    });
  });

  it('should allow admin-only endpoints for admins', async () => {
    const response = await request(app)
      .get('/api/admin/users')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    expect(Array.isArray(response.body.data)).toBe(true);
  });

  it('should deny admin-only endpoints for regular users', async () => {
    const response = await request(app)
      .get('/api/admin/users')
      .set('Authorization', `Bearer ${userToken}`)
      .expect(403);

    expect(response.body).toMatchObject({
      success: false,
      error: {
        code: 'FORBIDDEN'
      }
    });
  });
});
```

### 3. Error Handling

```typescript
describe('Error Handling', () => {
  it('should handle validation errors', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        name: 'J',
        email: 'invalid-email'
      })
      .expect(400);

    expect(response.body).toMatchObject({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        details: expect.any(Object)
      }
    });
  });

  it('should handle not found errors', async () => {
    const response = await request(app)
      .get('/api/users/non-existent')
      .expect(404);

    expect(response.body).toMatchObject({
      success: false,
      error: {
        code: 'NOT_FOUND',
        message: expect.any(String)
      }
    });
  });

  it('should handle server errors', async () => {
    // Mock a server error
    jest.spyOn(UserService, 'findById').mockRejectedValue(new Error('Database error'));

    const response = await request(app)
      .get('/api/users/123')
      .expect(500);

    expect(response.body).toMatchObject({
      success: false,
      error: {
        code: 'INTERNAL_SERVER_ERROR'
      }
    });
  });
});
```

### 4. Rate Limiting

```typescript
describe('Rate Limiting', () => {
  it('should allow requests within rate limit', async () => {
    const promises = Array(5).fill(null).map(() =>
      request(app).get('/api/users')
    );

    const responses = await Promise.all(promises);

    responses.forEach(response => {
      expect([200, 429]).toContain(response.status);
    });
  });

  it('should rate limit after threshold', async () => {
    const promises = Array(20).fill(null).map(() =>
      request(app).get('/api/users')
    );

    const responses = await Promise.all(promises);

    const rateLimitedResponses = responses.filter(r => r.status === 429);
    expect(rateLimitedResponses.length).toBeGreaterThan(0);
  });

  it('should include rate limit headers', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200);

    expect(response.headers).toHaveProperty('x-ratelimit-limit');
    expect(response.headers).toHaveProperty('x-ratelimit-remaining');
    expect(response.headers).toHaveProperty('x-ratelimit-reset');
  });
});
```

## Test Utilities

### Authentication Helper

```typescript
// ✅ Good: Test utilities
export async function createTestUser(overrides = {}) {
  return await User.create({
    name: 'Test User',
    email: `test-${Date.now()}@example.com`,
    password: await bcrypt.hash('password123', 10),
    ...overrides
  });
}

export async function generateTestToken(user: User) {
  return jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
}

export async function authenticateTestRequest(app: Express) {
  const user = await createTestUser();
  const token = await generateTestToken(user);

  return {
    user,
    token,
    authenticatedRequest: request(app).set('Authorization', `Bearer ${token}`)
  };
}
```

### Database Helper

```typescript
export async function setupTestDatabase() {
  await db.migrate.latest();
  await db.seed.run();
}

export async function cleanupTestDatabase() {
  await db('users').truncate();
  await db('todos').truncate();
}

export async function withTestDatabase(fn: () => Promise<void>) {
  await setupTestDatabase();
  try {
    await fn();
  } finally {
    await cleanupTestDatabase();
  }
}
```

## Contract Testing

### OpenAPI Schema Validation

```typescript
// ✅ Good: Contract testing
import { validateAgainstSchema } from './test-utils';

describe('API Contract Tests', () => {
  it('should match OpenAPI schema for GET /api/users/:id', async () => {
    const user = await createTestUser();
    const response = await request(app)
      .get(`/api/users/${user.id}`)
      .expect(200);

    const isValid = await validateAgainstSchema(
      'User',
      response.body.data
    );

    expect(isValid).toBe(true);
  });

  it('should match error schema for 404 responses', async () => {
    const response = await request(app)
      .get('/api/users/non-existent')
      .expect(404);

    const isValid = await validateAgainstSchema(
      'ErrorResponse',
      response.body
    );

    expect(isValid).toBe(true);
  });
});
```

## API Contract Testing with Structured Validation

### Contract Interface

Define structured API contracts that validate input, expected output, actual output, and response time:

```typescript
interface APIContract {
  endpoint: string;
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  description: string;

  request: {
    headers?: Record<string, string>;
    query?: Record<string, string>;
    body?: unknown;
  };

  expected: {
    status: number;
    body?: unknown;
    headers?: Record<string, string>;
    maxResponseTime: number; // milliseconds
  };

  actual: {
    status?: number;
    body?: unknown;
    headers?: Record<string, string>;
    responseTime?: number;
  };

  result: 'PASS' | 'FAIL' | 'NOT_RUN';
  failureReason?: string;
}
```

### Contract Test Example

```typescript
describe('API Contract: POST /api/users', () => {
  const contracts: APIContract[] = [
    {
      endpoint: '/api/users',
      method: 'POST',
      description: 'Create user with valid data',
      request: {
        body: { name: 'John Doe', email: 'john@example.com', password: 'SecurePass123!' }
      },
      expected: {
        status: 201,
        body: { success: true, data: { name: 'John Doe', email: 'john@example.com' } },
        maxResponseTime: 500
      },
      actual: {},
      result: 'NOT_RUN'
    },
    {
      endpoint: '/api/users',
      method: 'POST',
      description: 'Reject invalid email',
      request: {
        body: { name: 'Jane', email: 'not-an-email', password: 'short' }
      },
      expected: {
        status: 400,
        body: { success: false, error: { code: 'VALIDATION_ERROR' } },
        maxResponseTime: 200
      },
      actual: {},
      result: 'NOT_RUN'
    }
  ];

  for (const contract of contracts) {
    it(contract.description, async () => {
      const start = performance.now();
      const response = await request(app)
        [contract.method.toLowerCase()](contract.endpoint)
        .set(contract.request.headers || {})
        .query(contract.request.query || {})
        .send(contract.request.body);
      const responseTime = performance.now() - start;

      contract.actual = {
        status: response.status,
        body: response.body,
        responseTime
      };

      // Validate status
      expect(response.status).toBe(contract.expected.status);

      // Validate body shape
      if (contract.expected.body) {
        expect(response.body).toMatchObject(contract.expected.body);
      }

      // Validate response time SLA
      expect(responseTime).toBeLessThan(contract.expected.maxResponseTime);

      contract.result = 'PASS';
    });
  }

  afterAll(() => {
    // Print contract report
    console.table(contracts.map(c => ({
      Description: c.description,
      Expected: c.expected.status,
      Actual: c.actual.status,
      'Time (ms)': c.actual.responseTime?.toFixed(1),
      'SLA (ms)': c.expected.maxResponseTime,
      Result: c.result
    })));
  });
});
```

## Response Time Validation

### Per-Endpoint Thresholds

Define performance SLAs per endpoint:

```typescript
const endpointThresholds: Record<string, { p50: number; p95: number; p99: number }> = {
  'GET /api/users':       { p50: 100, p95: 300,  p99: 500  },
  'POST /api/users':      { p50: 200, p95: 500,  p99: 1000 },
  'GET /api/users/:id':   { p50: 50,  p95: 150,  p99: 300  },
  'PATCH /api/users/:id': { p50: 150, p95: 400,  p99: 800  },
  'DELETE /api/users/:id':{ p50: 100, p95: 300,  p99: 600  },
  'POST /api/auth/login': { p50: 100, p95: 300,  p99: 500  },
};
```

### Percentile Timing Test

```typescript
describe('API Performance: GET /api/users', () => {
  const THRESHOLD_P95 = 300;
  const SAMPLE_SIZE = 50;
  const responseTimes: number[] = [];

  for (let i = 0; i < SAMPLE_SIZE; i++) {
    it(`sample ${i + 1}`, async () => {
      const start = performance.now();
      await request(app).get('/api/users').set('Authorization', `Bearer ${token}`).expect(200);
      responseTimes.push(performance.now() - start);
    });
  }

  afterAll(() => {
    responseTimes.sort((a, b) => a - b);
    const p50 = responseTimes[Math.floor(SAMPLE_SIZE * 0.5)];
    const p95 = responseTimes[Math.floor(SAMPLE_SIZE * 0.95)];
    const p99 = responseTimes[Math.floor(SAMPLE_SIZE * 0.99)];

    console.log(`P50: ${p50.toFixed(2)}ms`);
    console.log(`P95: ${p95.toFixed(2)}ms`);
    console.log(`P99: ${p99.toFixed(2)}ms`);

    expect(p95).toBeLessThan(THRESHOLD_P95);
  });
});
```

## API Performance Benchmarking

### Benchmark Runner

```typescript
interface BenchmarkResult {
  endpoint: string;
  method: string;
  samples: number;
  p50: number;
  p95: number;
  p99: number;
  min: number;
  max: number;
  mean: number;
  passed: boolean;
}

async function benchmarkEndpoint(
  app: Express,
  method: string,
  endpoint: string,
  threshold: { p95: number },
  options: { samples?: number; headers?: Record<string, string>; body?: unknown } = {}
): Promise<BenchmarkResult> {
  const samples = options.samples ?? 30;
  const times: number[] = [];

  for (let i = 0; i < samples; i++) {
    const start = performance.now();
    await request(app)
      [method.toLowerCase()](endpoint)
      .set(options.headers || {})
      .send(options.body);
    times.push(performance.now() - start);
  }

  times.sort((a, b) => a - b);
  const p50 = times[Math.floor(samples * 0.5)];
  const p95 = times[Math.floor(samples * 0.95)];
  const p99 = times[Math.floor(samples * 0.99)];

  return {
    endpoint,
    method,
    samples,
    p50,
    p95,
    p99,
    min: times[0],
    max: times[samples - 1],
    mean: times.reduce((a, b) => a + b) / samples,
    passed: p95 < threshold.p95
  };
}
```

### Benchmark Suite

```typescript
describe('API Performance Benchmark Suite', () => {
  const results: BenchmarkResult[] = [];

  it('GET /api/users', async () => {
    const result = await benchmarkEndpoint(app, 'GET', '/api/users',
      { p95: 300 }, { headers: { Authorization: `Bearer ${token}` } });
    results.push(result);
    expect(result.passed).toBe(true);
  });

  it('GET /api/users/:id', async () => {
    const result = await benchmarkEndpoint(app, 'GET', '/api/users/1',
      { p95: 150 }, { headers: { Authorization: `Bearer ${token}` } });
    results.push(result);
    expect(result.passed).toBe(true);
  });

  it('POST /api/users', async () => {
    const result = await benchmarkEndpoint(app, 'POST', '/api/users',
      { p95: 500 }, {
        headers: { Authorization: `Bearer ${adminToken}` },
        body: { name: 'Benchmark User', email: `bench${Date.now()}@test.com`, password: 'TestPass123!' }
      });
    results.push(result);
    expect(result.passed).toBe(true);
  });

  afterAll(() => {
    console.log('\n## API Performance Benchmark Report\n');
    console.log('| Endpoint | P50 | P95 | P99 | Min | Max | Mean | Status |');
    console.log('|---|---|---|---|---|---|---|---|');
    for (const r of results) {
      console.log(`| ${r.method} ${r.endpoint} | ${r.p50.toFixed(0)}ms | ${r.p95.toFixed(0)}ms | ${r.p99.toFixed(0)}ms | ${r.min.toFixed(0)}ms | ${r.max.toFixed(0)}ms | ${r.mean.toFixed(0)}ms | ${r.passed ? 'PASS' : 'FAIL'} |`);
    }
  });
});
```

## Best Practices

### 1. Use Descriptive Test Names

```typescript
// ❌ Bad: Vague test names
it('should work', async () => {});
it('should fail', async () => {});

// ✅ Good: Descriptive test names
it('should create user with valid data', async () => {});
it('should return 400 when email is invalid', async () => {});
```

### 2. Test Independent States

```typescript
// ❌ Bad: Tests depend on order
describe('User API', () => {
  let userId: string;

  it('should create user', async () => {
    // Creates user
  });

  it('should get user', async () => {
    // Depends on previous test creating user
  });
});

// ✅ Good: Each test is independent
describe('User API', () => {
  it('should create and get user', async () => {
    const user = await createTestUser();
    const response = await request(app).get(`/api/users/${user.id}`);
    expect(response.status).toBe(200);
  });
});
```

### 3. Use Test Database

```typescript
// ✅ Good: Use test database
beforeEach(async () => {
  await setupTestDatabase();
});

afterEach(async () => {
  await cleanupTestDatabase();
});
```

## Coaching Notes

> **ABC - Always Be Coaching:** API tests are your contract with every client that consumes your service -- write them as if the next consumer is a team you have never met.

1. **Test the Contract, Not the Implementation:** Your API tests should verify what the endpoint promises (status codes, response shapes, headers) not how it works internally. Implementation tests break on refactors; contract tests do not.
2. **Make Each Test Independent and Repeatable:** If a test only passes when it runs in a specific order, it is hiding bugs. Use setup and teardown to guarantee a clean state for every test.
3. **Error Paths Are First-Class Citizens:** Most production incidents come from untested error conditions. Spend equal time crafting test cases for 400, 401, 403, 404, and 500 responses as you do for the 200 happy path.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Testing implementation | Brittle tests | Test contracts |
| No cleanup | Side effects | Clean up after tests |
| Hardcoded data | Conflicts | Use unique test data |
| No authentication tests | Security gaps | Test auth/authorization |
| Missing error tests | Poor error handling | Test error cases |

## Verification

After API testing:

- [ ] All endpoints tested
- [ ] Error cases covered
- [ ] Authentication tested
- [ ] Authorization tested
- [ ] Contracts validated
- [ ] Rate limiting tested
- [ ] Input validation tested
- [ ] Tests are isolated
- [ ] Tests are fast
- [ ] API contracts validated (input/output/status)
- [ ] Response time thresholds tested
- [ ] Performance benchmarks run for critical endpoints
- [ ] Contract test report generated
