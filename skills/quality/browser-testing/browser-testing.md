---
name: browser-testing
description: Browser testing using DevTools and headless browsers with video recording and test evidence collection. Use when testing web applications, debugging frontend issues, or verifying user interactions.
version: "3.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["browser test", "playwright", "devtools", "frontend debug", "video record", "screen recording", "test evidence"]
intent: "Validate real user experience by automating browser interactions, recording video evidence, and catching rendering bugs that unit tests cannot detect."
scenarios:
  - "Automating a login flow test that verifies redirect, cookie behavior, and error messages"
  - "Testing responsive layout across mobile, tablet, and desktop viewports"
  - "Capturing screenshots on test failure to debug a CSS regression in production"
  - "Recording a full user session video to attach as evidence in a bug report"
best_for: "frontend QA, cross-browser testing, responsive testing, visual debugging, user interaction verification, video recording, test evidence collection"
estimated_time: "15-30 min"
anti_patterns:
  - "Using brittle CSS selectors that break whenever a developer changes a class name"
  - "Using fixed sleep waits instead of waiting for elements or network idle"
  - "Testing internal implementation state instead of user-visible behavior"
related_skills: ["e2e-testing", "frontend-patterns", "performance-optimization", "test-generation"]
---

# Browser Testing

## Overview

Browser testing verifies web applications work correctly across different browsers and devices. Using DevTools and headless browsers enables automated testing, debugging, and quality assurance.

## When to Use

- Testing web applications
- Debugging frontend issues
- Verifying user interactions
- Testing responsive design
- Cross-browser compatibility

## Universal Browser Authentication

### Decision Matrix

| Auth Type | Method | How It Works |
|---|---|---|
| **Any auth (MSAL, OAuth, SSO, JWT, Cookie)** | **storageState** (recommended) | Login once manually, Playwright saves full session |
| Simple JWT in localStorage | Token injection | Set localStorage directly |
| Cookie-based session | Cookie import | Import via gstack cookie-picker |
| Bearer token API | extraHTTPHeaders | Set Authorization header in config |

### Method 1: storageState — Works for ALL auth types (Recommended)

Playwright saves complete browser state (cookies + localStorage + sessionStorage + indexedDB). Works for MSAL, Azure AD, OAuth, SSO, and any auth that stores state in the browser.

**Setup (run once):**

```bash
node scripts/test-web-auth.js setup https://your-app.example.com
```

Opens a visible browser. Login manually. After login detected, state is saved to `.auth/storage-state.json` (gitignored).

**Run tests (uses saved state):**

```bash
node scripts/test-web-auth.js test
```

**Check state:**

```bash
node scripts/test-web-auth.js status
```

**In Playwright tests:**

```typescript
import { test, expect } from '@playwright/test';
import { readFileSync } from 'fs';

const authState = JSON.parse(readFileSync('.auth/storage-state.json', 'utf-8'));

test.use({ storageState: '.auth/storage-state.json' });

test('should access protected page', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
});
```

**In playwright.config.ts (global):**

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    storageState: '.auth/storage-state.json',
    recordVideo: { dir: 'test-results/videos/', size: { width: 1280, height: 720 } },
  },
});
```

### Method 2: Token Injection (Simple JWT/localStorage only)

For apps that store plain JWT tokens in localStorage (not MSAL — MSAL encrypts tokens):

```typescript
test.beforeEach(async ({ page }) => {
  await page.goto('/');
  await page.evaluate(({ access, refresh }) => {
    localStorage.setItem('accessToken', access);
    localStorage.setItem('refreshToken', refresh);
  }, { access: tokens.accessToken, refresh: tokens.refreshToken });
  await page.reload();
});
```

### Method 3: Cookie Import via gstack

For cookie-based auth, import from real browser:

```bash
# Opens cookie picker UI
browse cookie-import-browser

# Or import specific domain
browse cookie-import-browser Chrome --domain example.com
```

### Token Refresh Pattern

For APIs that use expiring tokens:

```typescript
test.beforeEach(async ({ page }) => {
  await page.route('**/api/**', async (route) => {
    const response = await route.fetch({
      headers: {
        ...route.request().headers(),
        'Authorization': `Bearer ${tokens.accessToken}`,
      },
    });
    if (response.status() === 401) {
      const refreshResponse = await fetch(`${baseUrl}/api/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: tokens.refreshToken }),
      });
      const { accessToken: newToken } = await refreshResponse.json();
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify(await (await route.fetch({
          headers: { ...route.request().headers(), 'Authorization': `Bearer ${newToken}` },
        })).json()),
      });
    } else {
      await route.fulfill({ response });
    }
  });
});
```

## Browser Testing Tools

### 1. Chrome DevTools Protocol

Use DevTools for live debugging:

```typescript
// ✅ Good: Using DevTools MCP for testing
import { chromium } from 'playwright';

async function testLoginPage() {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to login page
  await page.goto('http://localhost:3000/login');

  // Fill login form
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');

  // Submit form
  await page.click('button[type="submit"]');

  // Wait for navigation
  await page.waitForURL('**/dashboard');

  // Verify success
  const title = await page.title();
  expect(title).toBe('Dashboard');

  await browser.close();
}
```

### 2. Playwright for E2E Testing

Automated browser testing:

```typescript
// ✅ Good: Playwright E2E test
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="login-button"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');
    await page.click('[data-testid="login-button"]');

    await expect(page.locator('[data-testid="error-message"]')).toHaveText(
      'Invalid email or password'
    );
  });
});
```

## Testing Scenarios

### 1. User Interactions

Test user workflows:

```typescript
test.describe('Shopping Cart', () => {
  test('should add item to cart', async ({ page }) => {
    await page.goto('/products');

    await page.click('[data-product-id="1"] [data-testid="add-to-cart"]');
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('1');
  });

  test('should remove item from cart', async ({ page }) => {
    await page.goto('/cart');

    await page.click('[data-testid="remove-item-1"]');
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('0');
  });

  test('should checkout successfully', async ({ page }) => {
    await page.goto('/cart');

    await page.click('[data-testid="checkout-button"]');
    await page.fill('[data-testid="card-number"]', '4242424242424242');
    await page.fill('[data-testid="card-expiry"]', '12/25');
    await page.fill('[data-testid="card-cvc"]', '123');
    await page.click('[data-testid="pay-button"]');

    await expect(page).toHaveURL('/order-confirmation');
  });
});
```

### 2. Responsive Design

Test different screen sizes:

```typescript
const devices = [
  { name: 'iPhone', viewport: { width: 375, height: 667 } },
  { name: 'iPad', viewport: { width: 768, height: 1024 } },
  { name: 'Desktop', viewport: { width: 1920, height: 1080 } }
];

for (const device of devices) {
  test(`should work on ${device.name}`, async ({ page }) => {
    await page.setViewportSize(device.viewport);
    await page.goto('/');

    // Test that layout works on this device
    await expect(page.locator('[data-testid="main-navigation"]')).toBeVisible();
  });
}
```

### 3. Form Validation

Test form behavior:

```typescript
test.describe('Contact Form', () => {
  test('should validate required fields', async ({ page }) => {
    await page.goto('/contact');

    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[data-testid="name-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="message-error"]')).toBeVisible();
  });

  test('should validate email format', async ({ page }) => {
    await page.goto('/contact');

    await page.fill('[data-testid="email-input"]', 'not-an-email');
    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[data-testid="email-error"]')).toHaveText(
      'Invalid email format'
    );
  });

  test('should submit successfully with valid data', async ({ page }) => {
    await page.goto('/contact');

    await page.fill('[data-testid="name-input"]', 'John Doe');
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.fill('[data-testid="message-input"]', 'Test message');

    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
  });
});
```

### 4. Network Interactions

Test API calls:

```typescript
test('should handle API errors gracefully', async ({ page }) => {
  // Mock API error
  await page.route('**/api/users', route => {
    route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal server error' })
    });
  });

  await page.goto('/users');

  await expect(page.locator('[data-testid="error-message"]')).toBeVisible();
  await expect(page.locator('[data-testid="error-message"]')).toHaveText(
    'Failed to load users. Please try again.'
  );
});
```

## Testing Best Practices

### 1. Use Data Attributes

Use data attributes for selectors:

```typescript
// ❌ Bad: Brittle selectors
await page.click('.btn-primary');
await page.click('#submit-btn');
await page.click('button[type="submit"]');

// ✅ Good: Stable data attributes
await page.click('[data-testid="submit-button"]');
```

### 2. Wait for Elements

Wait for elements to be ready:

```typescript
// ❌ Bad: No waiting
await page.click('[data-testid="submit-button"]');
expect(await page.textContent('[data-testid="result"]')).toBe('Success');

// ✅ Good: Explicit wait
await page.click('[data-testid="submit-button"]');
await page.waitForSelector('[data-testid="result"]');
await expect(page.locator('[data-testid="result"]')).toHaveText('Success');
```

### 3. Test User-Visible Behavior

Test what users see, not implementation:

```typescript
// ❌ Bad: Testing implementation
expect(state.isLoading).toBe(false);
expect(state.data).toHaveLength(10);

// ✅ Good: Testing user-visible behavior
await expect(page.locator('[data-testid="loading-spinner"]')).not.toBeVisible();
await expect(page.locator('[data-testid="user-list"]')).toHaveCount(10);
```

## Debugging Tools

### 1. Screenshots

Capture screenshots for debugging:

```typescript
test('should capture screenshot on failure', async ({ page }) => {
  try {
    await page.goto('/complex-page');
    await performComplexInteractions(page);
  } catch (error) {
    await page.screenshot({ path: 'failure-screenshot.png' });
    throw error;
  }
});
```

### 2. Tracing

Enable tracing for debugging:

```typescript
test('should trace test execution', async ({ page }) => {
  await page.context().tracing.start({ screenshots: true, snapshots: true });

  try {
    await page.goto('/');
    await page.click('[data-testid="button"]');
  } finally {
    await page.context().tracing.stop({ path: 'trace.zip' });
  }
});
```

### 3. Console Logs

Capture console logs:

```typescript
test('should capture console errors', async ({ page }) => {
  const errors: string[] = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
    }
  });

  await page.goto('/page-with-errors');

  expect(errors).toHaveLength(0);
});
```

## Video Recording

### Enabling Video Recording

Playwright supports built-in video recording at the browser context level:

```typescript
// Enable video recording for all tests in a context
const context = await browser.newContext({
  recordVideo: {
    dir: 'test-results/videos/',
    size: { width: 1280, height: 720 }
  }
});
```

### Global Video Configuration

Configure video recording in `playwright.config.ts`:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: {
    recordVideo: {
      dir: 'test-results/videos/',
      size: { width: 1280, height: 720 }
    }
  }
});
```

### Save Video on Failure

Automatically save video evidence when a test fails:

```typescript
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== testInfo.expectedStatus) {
    const video = page.video();
    if (video) {
      const videoPath = `test-results/videos/${testInfo.title}-failure.webm`;
      await video.saveAs(videoPath);
    }
  }
});
```

### Combined Evidence Collection

Capture the full evidence triad — screenshot + video + trace — for debugging:

```typescript
test('should capture full evidence on failure', async ({ page, context }, testInfo) => {
  // Start tracing with screenshots and snapshots
  await context.tracing.start({ screenshots: true, snapshots: true, sources: true });

  try {
    await page.goto('/dashboard');
    await performComplexWorkflow(page);
  } catch (error) {
    // Capture screenshot at point of failure
    await page.screenshot({ path: `test-results/screenshots/${testInfo.title}-failure.png` });

    // Video is automatically recorded by context config
    const video = page.video();
    if (video) {
      await video.saveAs(`test-results/videos/${testInfo.title}-failure.webm`);
    }

    throw error;
  } finally {
    // Stop and save trace
    await context.tracing.stop({ path: `test-results/traces/${testInfo.title}.zip` });
  }
});
```

## Test Evidence Collection

### Evidence Directory Structure

```
test-results/
├── videos/          # .webm video files per test
├── screenshots/     # .png screenshots on failure
├── traces/          # .zip Playwright traces
└── reports/
    └── evidence-report.html  # Combined evidence report
```

### Evidence Metadata

```typescript
interface TestEvidence {
  testName: string;
  timestamp: string;
  status: 'passed' | 'failed';
  duration: number;
  screenshots: string[];
  videoPath: string;
  tracePath: string;
  consoleErrors: string[];
  networkErrors: string[];
}
```

### Collecting Evidence Automatically

```typescript
import { test, expect } from '@playwright/test';

const evidence: TestEvidence[] = [];

test.afterEach(async ({ page }, testInfo) => {
  const entry: TestEvidence = {
    testName: testInfo.title,
    timestamp: new Date().toISOString(),
    status: testInfo.status as 'passed' | 'failed',
    duration: testInfo.duration,
    screenshots: [],
    videoPath: '',
    tracePath: '',
    consoleErrors: [],
    networkErrors: []
  };

  // Collect video
  const video = page.video();
  if (video) {
    const videoPath = `test-results/videos/${testInfo.title}-${testInfo.status}.webm`;
    await video.saveAs(videoPath);
    entry.videoPath = videoPath;
  }

  // Collect screenshot on failure
  if (testInfo.status === 'failed') {
    const screenshotPath = `test-results/screenshots/${testInfo.title}-failure.png`;
    await page.screenshot({ path: screenshotPath });
    entry.screenshots.push(screenshotPath);
  }

  evidence.push(entry);
});

test.afterAll(async () => {
  // Generate evidence report
  const report = generateEvidenceReport(evidence);
  require('fs').writeFileSync('test-results/reports/evidence-report.html', report);
});
```

### Evidence Report Generation

Generate an HTML report with embedded video evidence:

```typescript
function generateEvidenceReport(evidence: TestEvidence[]): string {
  const rows = evidence.map(e => `
    <div class="test-evidence" style="border: 1px solid #ddd; margin: 16px 0; padding: 16px; border-radius: 8px;">
      <h2 style="margin-top: 0;">${e.testName}</h2>
      <p><strong>Status:</strong> <span style="color: ${e.status === 'passed' ? 'green' : 'red'}">${e.status.toUpperCase()}</span></p>
      <p><strong>Duration:</strong> ${e.duration}ms | <strong>Time:</strong> ${e.timestamp}</p>
      ${e.videoPath ? `<video src="${e.videoPath}" controls width="640" style="border: 1px solid #ccc;"></video>` : ''}
      ${e.screenshots.length > 0 ? e.screenshots.map(s => `<img src="${s}" width="320" style="border: 1px solid #ccc; margin: 8px;" />`).join('') : ''}
      ${e.consoleErrors.length > 0 ? `<h3>Console Errors</h3><pre>${e.consoleErrors.join('\n')}</pre>` : ''}
    </div>
  `);

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Test Evidence Report</title>
      <style>body { font-family: system-ui, sans-serif; max-width: 960px; margin: 0 auto; padding: 20px; }</style>
    </head>
    <body>
      <h1>Test Evidence Report</h1>
      <p>Generated: ${new Date().toISOString()} | Total: ${evidence.length} | Failed: ${evidence.filter(e => e.status === 'failed').length}</p>
      ${rows.join('')}
    </body>
    </html>
  `;
}
```

## Cross-Browser Testing

Test across different browsers:

```typescript
const browsers = ['chromium', 'firefox', 'webkit'];

for (const browserType of browsers) {
  test(`should work in ${browserType}`, async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('[data-testid="main-content"]')).toBeVisible();
  });
}
```

## Coaching Notes

> **ABC - Always Be Coaching:** Browser tests simulate real users -- think like a user, test like a user, and never trust that the frontend works until you see it rendered.

1. **Test What Users See, Not What the Code Does:** A user does not care about component state or store values. They care that the button is visible, the form submits, and the error message appears. Assert on visible behavior.
2. **Use Stable Selectors or Regret It Later:** Data attributes (`data-testid`) are your contract between test and UI. CSS classes change during redesigns, IDs change during refactors, but `data-testid` changes only when the element is removed.
3. **Screenshots Are Your Safety Net:** Always capture screenshots on failure. A screenshot tells you in one second what a stack trace takes five minutes to diagnose. Enable tracing for complex flaky-test investigations.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Brittle selectors | Tests break with CSS changes | Use data attributes |
| No waiting | Flaky tests | Wait for elements |
| Testing implementation | Brittle tests | Test user-visible behavior |
| No cleanup | Side effects between tests | Isolate tests |
| Hardcoded waits | Slow tests | Use smart waits |

## Verification

After browser testing:

- [ ] Tests cover user workflows
- [ ] Tests are stable and reliable
- [ ] Tests run across browsers
- [ ] Tests are fast enough
- [ ] Screenshots captured on failure
- [ ] Console errors checked
- [ ] Network interactions tested
- [ ] Video recording configured for CI
- [ ] Evidence collected on failure (screenshot + video + trace)
- [ ] Evidence report generated
