const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const AUTH_FILE = path.join(__dirname, '../.auth/storage-state.json');
const BASE_URL = 'https://dev.apex.pinnacleunderwriting.com';

(async () => {
  console.log('Opening browser for manual login...');
  console.log('Please login to the app, then come back here and press Enter.\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
  console.log(`Opened: ${page.url()}`);
  console.log('Waiting for you to login...\n');

  // Wait for user to complete login (URL should change away from /login)
  await page.waitForURL(url => !url.toString().includes('/login'), { timeout: 300000 }).catch(() => {
    console.log('Timeout waiting for login (5 min). Continuing anyway...');
  });

  // Extra wait for page to fully load after login
  await page.waitForTimeout(3000);

  const currentUrl = page.url();
  console.log(`\nCurrent URL after login: ${currentUrl}`);

  // Save full storage state (cookies + localStorage + sessionStorage)
  fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });
  await context.storageState({ path: AUTH_FILE });

  console.log(`\nAuth state saved to: ${AUTH_FILE}`);
  console.log('This file contains your full session (cookies + localStorage).');
  console.log('It is gitignored and will be used for all future test runs.\n');

  // Verify the saved state
  const state = JSON.parse(fs.readFileSync(AUTH_FILE, 'utf-8'));
  console.log(`Cookies: ${state.cookies?.length || 0}`);
  console.log(`Origins in localStorage: ${state.origins?.length || 0}`);

  await browser.close();
  console.log('\nDone. You can now run tests with: node scripts/test-auth-recording.js');
})().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
