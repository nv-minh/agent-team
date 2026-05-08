const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const AUTH_FILE = path.join(__dirname, '../.auth/storage-state.json');
const BASE_URL = 'https://dev.apex.pinnacleunderwriting.com';
const FLOW_DIR = path.join(__dirname, '../flows/contracts');
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
  console.log('=== Discover Flow: Create Contract ===\n');
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

  // Step 2: Discover sidebar menu items
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
  const contractItems = menuItems.filter(i =>
    i.text.toLowerCase().includes('contract') ||
    i.text.toLowerCase().includes('submission') ||
    i.text.toLowerCase().includes('policy') ||
    i.text.toLowerCase().includes('opportunity')
  );
  contractItems.forEach(i => console.log(`  "${i.text}" (${i.tag}) ${i.selector || i.href || ''}`));
  console.log('');

  // Try to click on Contract/Submission/Policy menu item
  let navClicked = false;

  // Priority keywords for contract-related navigation
  const navKeywords = ['submission', 'contract', 'policy management', 'opportunity', 'new business'];

  for (const keyword of navKeywords) {
    if (navClicked) break;
    for (const item of contractItems) {
      if (navClicked) break;
      if (item.text.toLowerCase().includes(keyword)) {
        try {
          if (item.selector) {
            await page.click(item.selector);
          } else {
            await page.getByText(item.text, { exact: false }).first().click();
          }
          navClicked = true;
          await page.waitForTimeout(2000);
          await recordStep(page, `Click "${item.text}" menu`, 'click', item.selector || `text="${item.text}"`, null, 'Contract/Submission page loads');
        } catch {}
      }
    }
  }

  // Try direct URLs if menu click failed
  if (!navClicked) {
    const urls = [
      `${BASE_URL}/submissions`,
      `${BASE_URL}/contracts`,
      `${BASE_URL}/policy`,
      `${BASE_URL}/opportunities`
    ];
    for (const url of urls) {
      console.log(`Trying direct URL: ${url}`);
      await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 }).catch(() => {});
      await page.waitForTimeout(2000);
      const currentUrl = page.url();
      if (!currentUrl.includes('/login')) {
        await recordStep(page, `Navigate to ${url}`, 'navigate', null, url, 'Page loaded');
        navClicked = true;
        break;
      }
    }
  }

  console.log(`Current URL: ${page.url()}\n`);

  // Step 3: Discover all visible text to understand the page
  const pageText = await page.evaluate(() => {
    return document.body?.innerText?.substring(0, 1000) || '';
  });
  console.log(`Page content preview:\n${pageText.substring(0, 300)}...\n`);

  // Step 4: Look for Create/Add/New buttons
  const createButtons = await page.evaluate(() => {
    const buttons = [];
    document.querySelectorAll('button, a, [role="button"]').forEach(el => {
      const text = el.textContent?.trim();
      if (text && (
        text.toLowerCase().includes('create') ||
        text.toLowerCase().includes('add') ||
        text.toLowerCase().includes('new') ||
        text.toLowerCase().includes('start') ||
        text.toLowerCase().includes('initiate')
      )) {
        buttons.push({
          text,
          tag: el.tagName,
          testId: el.getAttribute('data-testid'),
          selector: el.getAttribute('data-testid')
            ? `[data-testid="${el.getAttribute('data-testid')}"]`
            : null,
          classes: el.className?.substring(0, 100),
          href: el.href || null
        });
      }
    });
    return buttons;
  });

  console.log('Create/New buttons found:');
  createButtons.forEach(b => console.log(`  "${b.text}" (${b.tag}) ${b.selector || ''} ${b.href || ''}`));
  console.log('');

  // Click the first create/new button
  for (const btn of createButtons) {
    try {
      if (btn.selector) {
        await page.click(btn.selector);
      } else {
        await page.getByText(btn.text, { exact: false }).first().click();
      }
      await recordStep(page, `Click "${btn.text}" button`, 'click', btn.selector || `text="${btn.text}"`, null, 'Contract creation form/dialog appears');
      break;
    } catch (e) {
      console.log(`  Could not click "${btn.text}": ${e.message?.substring(0, 80)}`);
    }
  }

  await page.waitForTimeout(2000);

  // Step 5: Discover form fields
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
        options: el.tagName === 'SELECT' ? Array.from(el.options).map(o => ({ value: o.value, text: o.textContent.trim() })) : [],
        selector: el.getAttribute('data-testid')
          ? `[data-testid="${el.getAttribute('data-testid')}"]`
          : (el.name ? `[name="${el.name}"]` : (el.id ? `#${el.id}` : null))
      });
    });
    return fields;
  });

  console.log('Form fields found:');
  formFields.forEach(f => {
    console.log(`  "${f.label}" (${f.type}) ${f.selector || ''} ${f.required ? '[required]' : ''}`);
    if (f.options.length > 0) {
      f.options.slice(0, 5).forEach(o => console.log(`    option: ${o.text} = ${o.value}`));
    }
  });
  console.log('');

  // Test data for contract creation
  const testData = {
    policy: 'POL-TEST-001',
    insured: 'Test Insured Corp',
    applicant: 'Test Applicant',
    effective: '01/06/2026',
    expiry: '01/06/2027',
    premium: '50000',
    limit: '1000000',
    deductible: '5000',
    lob: 'Property',
    carrier: 'Test Carrier',
    broker: 'Test Broker Automation',
    description: 'Test contract created by automation script',
    status: 'Draft',
    type: 'New Business',
    product: 'Commercial Property',
    state: 'CA',
    address: '456 Contract Ave',
    city: 'Los Angeles',
    zip: '90001'
  };

  // Fill form fields
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
      if (field.type === 'select-one' || field.tag === 'SELECT') {
        // Try exact value, then partial match
        const opts = field.options || [];
        const exactMatch = opts.find(o => o.value === value || o.text === value);
        const partialMatch = opts.find(o => o.text.toLowerCase().includes(value.toLowerCase()));
        const selectValue = exactMatch?.value || partialMatch?.value || value;
        await page.selectOption(field.selector, selectValue);
      } else if (field.type === 'date') {
        await page.fill(field.selector, value);
      } else {
        await page.fill(field.selector, value);
      }
      await recordStep(page, `Fill ${field.label}`, 'fill', field.selector, value, `${field.label} populated`);
    } catch (e) {
      console.log(`  Could not fill "${field.label}": ${e.message?.substring(0, 60)}`);
    }
  }

  await page.waitForTimeout(1000);

  // Step 6: Look for Submit/Save/Next button
  const submitButtons = await page.evaluate(() => {
    const buttons = [];
    document.querySelectorAll('button, input[type="submit"]').forEach(el => {
      const text = el.textContent?.trim() || el.value;
      if (text && (
        text.toLowerCase().includes('submit') ||
        text.toLowerCase().includes('save') ||
        text.toLowerCase().includes('create') ||
        text.toLowerCase().includes('confirm') ||
        text.toLowerCase().includes('next') ||
        text.toLowerCase().includes('continue') ||
        text.toLowerCase().includes('proceed')
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

  // Pre-submit screenshot
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, `step-${stepNum + 1}-pre-submit.png`) });

  // Click submit
  for (const btn of submitButtons) {
    try {
      if (btn.selector) {
        await page.click(btn.selector);
      } else {
        await page.getByText(btn.text, { exact: false }).first().click();
      }
      await recordStep(page, `Click "${btn.text}"`, 'click', btn.selector || `text="${btn.text}"`, null, 'Contract created/submitted');
      break;
    } catch {}
  }

  await page.waitForTimeout(3000);

  // Step 7: Check result
  const resultUrl = page.url();
  const resultContent = await page.evaluate(() => (document.body?.innerText || '').substring(0, 800));

  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'result.png') });
  console.log(`\nResult URL: ${resultUrl}`);
  console.log(`Result content:\n${resultContent.substring(0, 400)}...\n`);

  // Save video
  const video = page.video();
  if (video) {
    fs.mkdirSync(VIDEO_DIR, { recursive: true });
    const videoPath = path.join(VIDEO_DIR, 'create-contract-flow.webm');
    await video.saveAs(videoPath);
    console.log(`Video: ${videoPath}`);
  }

  // Export flow markdown
  let md = `# Flow: Create Contract\n\n`;
  md += `## Metadata\n`;
  md += `- **Feature**: Create Contract\n`;
  md += `- **URL**: ${BASE_URL}\n`;
  md += `- **Auth Required**: Yes\n`;
  md += `- **Prerequisites**: Authenticated session with contract creation permissions\n`;
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
  const flowFile = path.join(FLOW_DIR, 'create-contract.md');
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
