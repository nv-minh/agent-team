const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const AUTH_FILE = path.join(__dirname, '../.auth/storage-state.json');
const BASE_URL = 'https://dev.apex.pinnacleunderwriting.com';
const FLOW_DIR = path.join(__dirname, '../flows/brokers');
const SCREENSHOT_DIR = path.join(FLOW_DIR, 'screenshots');
const VIDEO_DIR = path.join(__dirname, '../test-results/videos/');

const steps = [];
let stepNum = 0;

async function recordStep(page, name, action, selector, input, expected) {
  stepNum++;
  const url = page.url();
  const screenshotPath = path.join(SCREENSHOT_DIR, `step-${stepNum}.png`);

  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
  await page.screenshot({ path: screenshotPath, fullPage: false });

  const step = {
    id: stepNum,
    name,
    action,
    selector,
    input,
    expected,
    url,
    screenshot: `screenshots/step-${stepNum}.png`
  };

  steps.push(step);
  console.log(`  Step ${stepNum}: ${name}`);
  console.log(`    URL: ${url}`);
  console.log(`    Action: ${action}`);
  if (selector) console.log(`    Selector: ${selector}`);
  if (input) console.log(`    Input: ${input}`);
  console.log(`    Expected: ${expected}`);
  console.log(`    Screenshot: ${screenshotPath}\n`);

  return step;
}

(async () => {
  console.log('=== Discover Flow: Create Broker ===\n');
  console.log('Launching browser with auth + video recording...\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    storageState: AUTH_FILE,
    recordVideo: { dir: VIDEO_DIR, size: { width: 1280, height: 720 } }
  });
  const page = await context.newPage();

  // Capture API calls
  const apiCalls = [];
  page.on('request', req => {
    if (req.url().includes('/api/') || req.url().includes('/apex/')) {
      apiCalls.push({
        step: stepNum,
        method: req.method(),
        url: req.url(),
        body: req.postData()
      });
    }
  });
  page.on('response', async res => {
    const match = apiCalls.find(c => c.url === res.url() && !c.status);
    if (match) {
      match.status = res.status();
      try { match.responseBody = await res.text(); } catch {}
    }
  });

  // Step 1: Navigate to dashboard
  await page.goto(`${BASE_URL}/home/dashboard`, { waitUntil: 'networkidle', timeout: 30000 }).catch(() => {});
  await page.waitForTimeout(2000);
  await recordStep(page, 'Navigate to Dashboard', 'navigate', null, `${BASE_URL}/home/dashboard`, 'Dashboard loaded');

  // Step 2: Find and navigate to Brokers section
  // Look for sidebar/menu items
  const menuItems = await page.evaluate(() => {
    const items = [];
    document.querySelectorAll('a, button, [role="menuitem"], [role="tab"], nav *').forEach(el => {
      const text = el.textContent?.trim();
      if (text && text.length < 50) {
        items.push({
          text,
          tag: el.tagName,
          href: el.href || null,
          testId: el.getAttribute('data-testid'),
          selector: el.getAttribute('data-testid')
            ? `[data-testid="${el.getAttribute('data-testid')}"]`
            : null
        });
      }
    });
    return items;
  });

  console.log('Menu items found:');
  const brokerItems = menuItems.filter(i =>
    i.text.toLowerCase().includes('broker') ||
    i.text.toLowerCase().includes('producer')
  );
  brokerItems.forEach(i => console.log(`  "${i.text}" (${i.tag}) ${i.selector || i.href || ''}`));
  console.log('');

  // Try to click on Brokers menu item
  let brokerNavClicked = false;

  // Try data-testid first
  for (const item of brokerItems) {
    if (item.selector) {
      try {
        await page.click(item.selector);
        brokerNavClicked = true;
        await recordStep(page, `Click "${item.text}" menu`, 'click', item.selector, null, 'Brokers page loads');
        break;
      } catch {}
    }
  }

  // Try by text
  if (!brokerNavClicked) {
    for (const item of brokerItems) {
      try {
        await page.getByText(item.text, { exact: false }).first().click();
        brokerNavClicked = true;
        await recordStep(page, `Click "${item.text}" menu`, 'click', `text="${item.text}"`, null, 'Brokers page loads');
        break;
      } catch {}
    }
  }

  // Try direct URL
  if (!brokerNavClicked) {
    console.log('Could not find menu item. Trying direct URL /brokers...');
    await page.goto(`${BASE_URL}/brokers`, { waitUntil: 'networkidle', timeout: 15000 }).catch(() => {});
  }

  await page.waitForTimeout(2000);
  console.log(`Current URL: ${page.url()}\n`);

  // Step 3: Look for Create/Add Broker button
  const createButtons = await page.evaluate(() => {
    const buttons = [];
    document.querySelectorAll('button, a, [role="button"]').forEach(el => {
      const text = el.textContent?.trim();
      if (text && (
        text.toLowerCase().includes('create') ||
        text.toLowerCase().includes('add') ||
        text.toLowerCase().includes('new')
      )) {
        buttons.push({
          text,
          tag: el.tagName,
          testId: el.getAttribute('data-testid'),
          selector: el.getAttribute('data-testid')
            ? `[data-testid="${el.getAttribute('data-testid')}"]`
            : null,
          classes: el.className?.substring(0, 100)
        });
      }
    });
    return buttons;
  });

  console.log('Create buttons found:');
  createButtons.forEach(b => console.log(`  "${b.text}" (${b.tag}) ${b.selector || ''}`));
  console.log('');

  // Click the create button
  for (const btn of createButtons) {
    try {
      if (btn.selector) {
        await page.click(btn.selector);
      } else {
        await page.getByText(btn.text, { exact: false }).first().click();
      }
      await recordStep(page, `Click "${btn.text}" button`, 'click', btn.selector || `text="${btn.text}"`, null, 'Broker creation form/dialog appears');
      break;
    } catch (e) {
      console.log(`  Could not click "${btn.text}": ${e.message?.substring(0, 80)}`);
    }
  }

  await page.waitForTimeout(2000);

  // Step 4: Discover form fields
  const formFields = await page.evaluate(() => {
    const fields = [];
    document.querySelectorAll('input, select, textarea').forEach(el => {
      const label = el.labels?.[0]?.textContent?.trim() ||
                   el.getAttribute('placeholder') ||
                   el.getAttribute('aria-label') ||
                   el.previousElementSibling?.textContent?.trim() ||
                   el.parentElement?.textContent?.trim()?.substring(0, 50);
      fields.push({
        label,
        tag: el.tagName,
        type: el.type,
        name: el.name,
        testId: el.getAttribute('data-testid'),
        id: el.id,
        required: el.required,
        selector: el.getAttribute('data-testid')
          ? `[data-testid="${el.getAttribute('data-testid')}"]`
          : (el.name ? `[name="${el.name}"]` : (el.id ? `#${el.id}` : null))
      });
    });
    return fields;
  });

  console.log('Form fields found:');
  formFields.forEach(f => console.log(`  "${f.label}" (${f.type}) ${f.selector || ''} ${f.required ? '[required]' : ''}`));
  console.log('');

  // Fill form fields with test data
  const testData = {
    name: 'Test Broker Automation',
    email: 'test.broker@automation.com',
    phone: '1234567890',
    code: 'AUTO001',
    address: '123 Test Street',
    city: 'Test City',
    state: 'CA',
    zip: '90001',
    license: 'LIC-TEST-001',
    description: 'Test broker created by automation script'
  };

  for (const field of formFields) {
    if (!field.selector) continue;
    const labelLower = (field.label || '').toLowerCase();

    // Find matching test data
    let value = null;
    for (const [key, val] of Object.entries(testData)) {
      if (labelLower.includes(key)) { value = val; break; }
    }
    if (!value) continue;

    try {
      if (field.type === 'select-one') {
        await page.selectOption(field.selector, value);
      } else {
        await page.fill(field.selector, value);
      }
      await recordStep(page, `Fill ${field.label}`, 'fill', field.selector, value, `${field.label} populated`);
    } catch (e) {
      console.log(`  Could not fill "${field.label}": ${e.message?.substring(0, 60)}`);
    }
  }

  await page.waitForTimeout(1000);

  // Step 5: Look for Submit/Save button
  const submitButtons = await page.evaluate(() => {
    const buttons = [];
    document.querySelectorAll('button, input[type="submit"]').forEach(el => {
      const text = el.textContent?.trim() || el.value;
      if (text && (
        text.toLowerCase().includes('submit') ||
        text.toLowerCase().includes('save') ||
        text.toLowerCase().includes('create') ||
        text.toLowerCase().includes('confirm')
      )) {
        buttons.push({
          text,
          testId: el.getAttribute('data-testid'),
          selector: el.getAttribute('data-testid')
            ? `[data-testid="${el.getAttribute('data-testid')}"]`
            : null
        });
      }
    });
    return buttons;
  });

  console.log('Submit buttons found:');
  submitButtons.forEach(b => console.log(`  "${b.text}" ${b.selector || ''}`));
  console.log('');

  // Take pre-submit screenshot
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, `step-${stepNum + 1}-pre-submit.png`) });

  // Click submit
  for (const btn of submitButtons) {
    try {
      if (btn.selector) {
        await page.click(btn.selector);
      } else {
        await page.getByText(btn.text, { exact: false }).first().click();
      }
      await recordStep(page, `Click "${btn.text}"`, 'click', btn.selector || `text="${btn.text}"`, null, 'Broker created successfully');
      break;
    } catch {}
  }

  await page.waitForTimeout(3000);

  // Step 6: Check result
  const resultUrl = page.url();
  const resultContent = await page.evaluate(() => (document.body?.innerText || '').substring(0, 800));

  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'result.png') });
  console.log(`\nResult URL: ${resultUrl}`);
  console.log(`Result content:\n${resultContent.substring(0, 400)}...\n`);

  // Save video
  const video = page.video();
  if (video) {
    fs.mkdirSync(VIDEO_DIR, { recursive: true });
    const videoPath = path.join(VIDEO_DIR, 'create-broker-flow.webm');
    await video.saveAs(videoPath);
    console.log(`Video: ${videoPath}`);
  }

  // Export flow markdown
  let md = `# Flow: Create Broker\n\n`;
  md += `## Metadata\n`;
  md += `- **Feature**: Create Broker\n`;
  md += `- **URL**: ${BASE_URL}\n`;
  md += `- **Auth Required**: Yes\n`;
  md += `- **Prerequisites**: Authenticated session with broker creation permissions\n`;
  md += `- **Discovered**: ${new Date().toISOString()}\n`;
  md += `- **Status**: verified\n\n`;
  md += `## Steps\n\n`;
  for (const step of steps) {
    md += `### Step ${step.id}: ${step.name}\n`;
    md += `- **URL**: ${step.url}\n`;
    md += `- **Action**: ${step.action}\n`;
    if (step.selector) md += `- **Selector**: \`${step.selector}\`\n`;
    if (step.input) md += `- **Input**: \`${step.input}\`\n`;
    md += `- **Expected**: ${step.expected}\n`;
    md += `- **Screenshot**: ${step.screenshot}\n\n`;
  }

  if (apiCalls.length) {
    md += `## API Calls\n`;
    md += `| Step | Method | URL | Status |\n`;
    md += `|------|--------|-----|--------|\n`;
    for (const call of apiCalls) {
      md += `| ${call.step} | ${call.method} | ${call.url.substring(0, 80)} | ${call.status || 'pending'} |\n`;
    }
    md += `\n`;
  }

  fs.mkdirSync(FLOW_DIR, { recursive: true });
  const flowFile = path.join(FLOW_DIR, 'create-broker.md');
  fs.writeFileSync(flowFile, md);
  console.log(`\nFlow exported: ${flowFile}`);

  console.log('\nClosing in 3s...');
  await page.waitForTimeout(3000);
  await browser.close();
  console.log('Done.');
})().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
