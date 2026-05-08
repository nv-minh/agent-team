---
name: flow-discovery
description: "Discover and document user flows on web applications. Agent explores the app, records each step (action, selector, input, expected result), exports a structured .md guide that can be replayed for automated testing."
version: "1.0.0"
category: "quality"
origin: "em-team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["discover flow", "record flow", "document flow", "flow discovery", "user flow", "step by step", "test flow"]
intent: "Explore a web application to discover and document complete user flows with structured step-by-step guides that agents can replay for automated testing."
scenarios:
  - "Agent explores the Create Broker flow and exports a step-by-step guide with selectors and screenshots"
  - "Recording the full Quote creation flow from login to submission"
  - "Documenting the Claims filing process for automated E2E test generation"
best_for: "flow documentation, step recording, user journey mapping, test flow export, replayable guides"
estimated_time: "15-45 min"
anti_patterns:
  - "Recording flows without verifying each step actually works"
  - "Using brittle selectors (CSS classes) instead of data-testid attributes"
  - "Documenting only the happy path without error/edge cases"
related_skills: ["browser-testing", "e2e-testing", "test-generation", "test-driven-development"]
---

# Flow Discovery

## Overview

Discover and document user flows on web applications. This skill guides an agent to explore a feature, record every step (action, selector, input, expected result), and export a structured `.md` file that can be replayed for automated testing.

## When to Use

- Need to document how a feature works for test automation
- Want a step-by-step guide that agents can follow to verify functionality
- Exploring a new feature before writing E2E tests
- Creating a reusable flow library for regression testing

## Flow Document Template

Every discovered flow is exported as a `.md` file with this structure:

```markdown
# Flow: [Flow Name]

## Metadata
- **Feature**: [Feature name]
- **URL**: [Starting URL]
- **Auth Required**: Yes/No
- **Prerequisites**: [What must be true before starting]
- **Discovered**: [Date]
- **Status**: [draft | verified | automated]

## Steps

### Step 1: [Action Name]
- **URL**: /current-page
- **Action**: click | fill | select | hover | navigate | wait
- **Selector**: [data-testid="element"] or CSS/XPath
- **Input**: [Value to enter, if any]
- **Expected Result**: [What should happen]
- **Screenshot**: flows/screenshots/step-1.png

### Step 2: [Action Name]
...

## Error Paths
### Step Xa: [Error condition]
- **Trigger**: [What causes the error]
- **Expected Error**: [Error message or behavior]
- **Recovery**: [How to get back on track]

## API Calls
| Step | Method | Endpoint | Request | Response |
|------|--------|----------|---------|----------|
| 1 | POST | /api/brokers | {...} | 201 {...} |

## Generated Test Code
[Playwright code generated from the flow]
```

## Discovery Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  1. PREPARE ──→ 2. EXPLORE ──→ 3. RECORD ──→ 4. VERIFY         │
│     Load auth      Navigate       Each step      Replay flow     │
│     Open app       Find elements   Screenshot     Confirm works  │
│                                                                  │
│  5. EXPORT ──→ 6. GENERATE                                      │
│     Write .md      Playwright code                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Step 1: PREPARE

Load authentication and open the application:

```javascript
const { chromium } = require('playwright');
const fs = require('fs');

const authState = JSON.parse(fs.readFileSync('.auth/storage-state.json', 'utf-8'));
const browser = await chromium.launch({ headless: false });
const context = await browser.newContext({
  storageState: '.auth/storage-state.json',
  recordVideo: { dir: 'flows/screenshots/', size: { width: 1280, height: 720 } }
});
const page = await context.newPage();
```

### Step 2: EXPLORE

Navigate to the feature and identify interactive elements:

```javascript
// Navigate to feature starting point
await page.goto('https://app.example.com/brokers');

// Discover interactive elements
const elements = await page.evaluate(() => {
  const interactives = [];
  document.querySelectorAll('a, button, input, select, textarea, [role="button"], [data-testid]').forEach(el => {
    interactives.push({
      tag: el.tagName,
      text: el.textContent?.trim()?.substring(0, 100),
      testId: el.getAttribute('data-testid'),
      id: el.id,
      type: el.type || el.getAttribute('role'),
      placeholder: el.placeholder,
      href: el.href,
      selector: el.getAttribute('data-testid')
        ? `[data-testid="${el.getAttribute('data-testid')}"]`
        : (el.id ? `#${el.id}` : null)
    });
  });
  return interactives.filter(e => e.testId || e.id || e.text);
});
```

### Step 3: RECORD

For each step, capture: action, selector, input, result, screenshot:

```javascript
const flow = {
  name: 'Create Broker',
  steps: [],
  apiCalls: []
};

// Record helper function
async function recordStep(page, step) {
  await page.screenshot({ path: `flows/screenshots/${step.id}.png` });

  // Capture network requests for this step
  const url = page.url();

  flow.steps.push({
    ...step,
    url,
    timestamp: new Date().toISOString(),
    screenshot: `flows/screenshots/${step.id}.png`
  });
}

// Example: Record a form fill step
await recordStep(page, {
  id: 'step-1',
  name: 'Click Create Broker button',
  action: 'click',
  selector: '[data-testid="create-broker-button"]',
  input: null,
  expected: 'Broker creation form appears'
});

await page.click('[data-testid="create-broker-button"]');
await page.waitForTimeout(1000);

await recordStep(page, {
  id: 'step-2',
  name: 'Fill broker name',
  action: 'fill',
  selector: '[data-testid="broker-name-input"]',
  input: 'Test Broker Corp',
  expected: 'Name field populated'
});

await page.fill('[data-testid="broker-name-input"]', 'Test Broker Corp');
```

### Step 4: VERIFY

Replay the recorded flow to confirm all steps work:

```javascript
// Replay: Start fresh and follow all recorded steps
const testPage = await testContext.newPage();
await testPage.goto(startUrl);

for (const step of flow.steps) {
  switch (step.action) {
    case 'click':
      await testPage.click(step.selector);
      break;
    case 'fill':
      await testPage.fill(step.selector, step.input);
      break;
    case 'select':
      await testPage.selectOption(step.selector, step.input);
      break;
    case 'navigate':
      await testPage.goto(step.input);
      break;
  }
  await testPage.waitForTimeout(500);

  // Verify expected result
  if (step.expected) {
    await testPage.screenshot({ path: `flows/verify/${step.id}.png` });
  }
}
```

### Step 5: EXPORT

Write the structured flow document:

```javascript
function exportFlowMarkdown(flow) {
  let md = `# Flow: ${flow.name}\n\n`;
  md += `## Metadata\n`;
  md += `- **Feature**: ${flow.feature}\n`;
  md += `- **URL**: ${flow.startUrl}\n`;
  md += `- **Auth Required**: ${flow.authRequired ? 'Yes' : 'No'}\n`;
  md += `- **Prerequisites**: ${flow.prerequisites}\n`;
  md += `- **Discovered**: ${new Date().toISOString()}\n`;
  md += `- **Status**: verified\n\n`;

  md += `## Steps\n\n`;
  for (const step of flow.steps) {
    md += `### Step ${step.id}: ${step.name}\n`;
    md += `- **URL**: ${step.url}\n`;
    md += `- **Action**: ${step.action}\n`;
    md += `- **Selector**: \`${step.selector}\`\n`;
    if (step.input) md += `- **Input**: \`${step.input}\`\n`;
    md += `- **Expected**: ${step.expected}\n`;
    md += `- **Screenshot**: ${step.screenshot}\n\n`;
  }

  if (flow.apiCalls?.length) {
    md += `## API Calls\n`;
    md += `| Step | Method | Endpoint | Status |\n`;
    md += `|------|--------|----------|--------|\n`;
    for (const call of flow.apiCalls) {
      md += `| ${call.step} | ${call.method} | ${call.endpoint} | ${call.status} |\n`;
    }
    md += `\n`;
  }

  return md;
}
```

### Step 6: GENERATE

Generate Playwright test code from the flow:

```javascript
function generatePlaywrightTest(flow) {
  let code = `import { test, expect } from '@playwright/test';\n\n`;
  code += `test.describe('${flow.name}', () => {\n`;
  code += `  test.use({ storageState: '.auth/storage-state.json' });\n\n`;
  code += `  test('should complete ${flow.name.toLowerCase()} flow', async ({ page }) => {\n`;

  for (const step of flow.steps) {
    code += `    // Step ${step.id}: ${step.name}\n`;
    switch (step.action) {
      case 'click':
        code += `    await page.click('${step.selector}');\n`;
        break;
      case 'fill':
        code += `    await page.fill('${step.selector}', '${step.input}');\n`;
        break;
      case 'select':
        code += `    await page.selectOption('${step.selector}', '${step.input}');\n`;
        break;
      case 'navigate':
        code += `    await page.goto('${step.input}');\n`;
        break;
    }
    if (step.expected) {
      code += `    // Expected: ${step.expected}\n`;
    }
    code += `\n`;
  }

  code += `  });\n`;
  code += `});\n`;
  return code;
}
```

## Network Request Capture

Capture API calls during flow discovery:

```javascript
const apiCalls = [];

page.on('request', request => {
  if (request.url().includes('/api/')) {
    apiCalls.push({
      method: request.method(),
      url: request.url(),
      body: request.postData()
    });
  }
});

page.on('response', async response => {
  const req = apiCalls.find(c => c.url === response.url() && !c.status);
  if (req) {
    req.status = response.status();
    try { req.response = await response.json(); } catch {}
  }
});
```

## Flow Document Directory

```
flows/
├── brokers/
│   ├── create-broker.md        # Flow document
│   ├── create-broker.spec.ts   # Generated Playwright test
│   └── screenshots/
│       ├── step-1.png
│       ├── step-2.png
│       └── ...
├── quotes/
│   ├── create-quote.md
│   └── ...
└── claims/
    ├── file-claim.md
    └── ...
```

## Coaching Notes

1. **Start from the user's perspective.** Ask "what does the user want to accomplish?" not "what buttons are on this page?" The flow should tell a story, not list DOM elements.
2. **Record selectors, not feelings.** `data-testid="submit-btn"` is permanent. "the blue button on the right" is not. Always prefer data-testid, then id, then aria-label. Never use CSS classes.
3. **Capture the network layer.** UI steps alone miss the API contract. Recording API calls alongside UI steps gives you both E2E and API test coverage from one discovery session.

## Verification

After flow discovery:

- [ ] All steps recorded with selectors
- [ ] Screenshots captured for each step
- [ ] API calls captured during flow
- [ ] Flow document exported to .md
- [ ] Playwright test code generated
- [ ] Flow replayed and verified
- [ ] Error paths documented (if any)
- [ ] Flow status set to "verified"
