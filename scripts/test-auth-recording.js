const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const AUTH_FILE = path.join(__dirname, '../.auth/storage-state.json');
const BASE_URL = 'https://dev.apex.pinnacleunderwriting.com';
const VIDEO_DIR = path.join(__dirname, '../test-results/videos/');
const SCREENSHOT_DIR = path.join(__dirname, '../test-results/screenshots/');

(async () => {
  if (!fs.existsSync(AUTH_FILE)) {
    console.error('Auth state not found. Run first: node scripts/setup-auth-state.js');
    process.exit(1);
  }

  console.log('Launching browser with saved auth state + video recording...');
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    storageState: AUTH_FILE,
    recordVideo: { dir: VIDEO_DIR, size: { width: 1280, height: 720 } }
  });
  const page = await context.newPage();

  console.log(`Navigating to ${BASE_URL}...`);
  await page.goto(BASE_URL, { waitUntil: 'networkidle', timeout: 30000 }).catch(() => {
    console.log('Note: networkidle timeout - continuing');
  });

  await page.waitForTimeout(3000);

  const currentUrl = page.url();
  const title = await page.title();
  console.log(`\nURL: ${currentUrl}`);
  console.log(`Title: ${title}`);

  const isOnDashboard = !currentUrl.includes('/login');
  console.log(`Authenticated: ${isOnDashboard}`);

  // Screenshot
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
  const screenshotPath = path.join(SCREENSHOT_DIR, 'dashboard-test.png');
  await page.screenshot({ path: screenshotPath, fullPage: false });
  console.log(`Screenshot: ${screenshotPath}`);

  // Content check
  const content = await page.evaluate(() => {
    const body = document.body?.innerText || '';
    const hasMenu = !!document.querySelector('nav, [class*="sidebar"], [class*="menu"], [class*="dashboard"], [class*="app"]');
    return { hasMenu, length: body.length, preview: body.substring(0, 500) };
  });
  console.log(`Dashboard elements: ${content.hasMenu}`);
  console.log(`Content length: ${content.length} chars`);
  if (content.preview.trim()) {
    console.log(`\nPreview:\n${content.preview.substring(0, 300)}...`);
  }

  // Save video
  const video = page.video();
  if (video) {
    fs.mkdirSync(VIDEO_DIR, { recursive: true });
    const videoPath = path.join(VIDEO_DIR, 'dashboard-auth-test.webm');
    await video.saveAs(videoPath);
    console.log(`\nVideo: ${videoPath}`);
  }

  console.log('\nClosing browser in 3 seconds...');
  await page.waitForTimeout(3000);
  await browser.close();
  console.log('Done.');
})().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
