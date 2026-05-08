const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const AUTH_FILE = path.join(__dirname, '../.auth/storage-state.json');
const CONFIG_FILE = path.join(__dirname, '../.auth/config.json');
const VIDEO_DIR = path.join(__dirname, '../test-results/videos/');
const SCREENSHOT_DIR = path.join(__dirname, '../test-results/screenshots/');
const DEFAULT_URL = 'https://dev.apex.pinnacleunderwriting.com';
const CDP_PORT = 9222;

function getConfig() {
  if (fs.existsSync(CONFIG_FILE)) {
    return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
  }
  return { baseUrl: DEFAULT_URL };
}

function saveConfig(config) {
  fs.mkdirSync(path.dirname(CONFIG_FILE), { recursive: true });
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
}

// ─── EXPORT: Connect to real browser, save session ─────────
async function exportSession(url) {
  const baseUrl = url || getConfig().baseUrl;

  console.log('=== Export Session from Real Browser ===\n');

  // Try to connect to user's real Chrome via CDP
  let browser;
  let connectedViaCDP = false;

  try {
    console.log(`Connecting to Chrome on port ${CDP_PORT}...`);
    browser = await chromium.connectOverCDP(`http://127.0.0.1:${CDP_PORT}`);
    connectedViaCDP = true;
    console.log('Connected to your real browser!\n');
  } catch {
    console.log('Could not connect to real browser via CDP.');
    console.log('To enable: close ALL Chrome windows, then run:');
    console.log('');
    console.log('  macOS:');
    console.log('    /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --remote-debugging-port=9222');
    console.log('');
    console.log('  Windows:');
    console.log('    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" --remote-debugging-port=9222');
    console.log('');
    console.log('Then re-run this script.\n');
    console.log('Falling back to Playwright browser for manual login...\n');

    browser = await chromium.launch({ headless: false });
  }

  const contexts = browser.contexts();
  const context = contexts[0] || await browser.newContext();
  const pages = context.pages();
  const page = pages[0] || await context.newPage();

  if (connectedViaCDP) {
    // Navigate to the app in the real browser
    console.log(`Navigating to ${baseUrl}...`);
    await page.goto(baseUrl, { waitUntil: 'networkidle', timeout: 30000 }).catch(() => {
      console.log('Page load timeout, continuing...');
    });
    await page.waitForTimeout(2000);

    const currentUrl = page.url();
    if (currentUrl.includes('/login') || currentUrl.includes('login.microsoft')) {
      console.log('\nYou are not logged in on this browser.');
      console.log('Please login in the Chrome window, then press Enter here...');
      // Wait for user input
      await new Promise(resolve => {
        process.stdin.once('data', () => resolve());
      });
      await page.waitForTimeout(2000);
    }
  } else {
    // Manual login flow
    await page.goto(baseUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
    console.log(`Opened: ${page.url()}`);
    console.log('Login manually, then press Enter here...');
    await new Promise(resolve => {
      process.stdin.once('data', () => resolve());
    });
    await page.waitForTimeout(2000);
  }

  // Save storage state
  fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });
  await context.storageState({ path: AUTH_FILE });

  const finalUrl = page.url();
  const state = JSON.parse(fs.readFileSync(AUTH_FILE, 'utf-8'));

  saveConfig({
    baseUrl,
    savedAt: new Date().toISOString(),
    dashboardUrl: finalUrl,
    method: connectedViaCDP ? 'cdp-export' : 'manual-login',
    cookies: state.cookies?.length || 0,
    origins: state.origins?.length || 0,
  });

  console.log(`\nSession exported: ${AUTH_FILE}`);
  console.log(`  Cookies: ${state.cookies?.length || 0}`);
  console.log(`  Origins (localStorage): ${state.origins?.length || 0}`);
  console.log(`  Method: ${connectedViaCDP ? 'CDP export from real browser' : 'Manual login'}`);
  console.log(`  Dashboard: ${finalUrl}`);

  if (!connectedViaCDP) {
    await browser.close();
  } else {
    console.log('\nNote: Your real browser stays open.');
  }

  console.log('\nDone. Run `node scripts/test-web-auth.js test` to use this session.');
}

// ─── TEST: Load state, record video ────────────────────────
async function test(url) {
  if (!fs.existsSync(AUTH_FILE)) {
    console.error('No auth state found.');
    console.error('Run first: node scripts/test-web-auth.js export');
    process.exit(1);
  }

  const baseUrl = url || getConfig().baseUrl || DEFAULT_URL;

  console.log('=== Test with Auth + Video Recording ===\n');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    storageState: AUTH_FILE,
    recordVideo: { dir: VIDEO_DIR, size: { width: 1280, height: 720 } }
  });
  const page = await context.newPage();

  console.log(`Navigating to ${baseUrl}...`);
  await page.goto(baseUrl, { waitUntil: 'networkidle', timeout: 30000 }).catch(() => {
    console.log('networkidle timeout, continuing...');
  });
  await page.waitForTimeout(3000);

  const currentUrl = page.url();
  const title = await page.title();
  const isAuth = !currentUrl.includes('/login') && !currentUrl.includes('login.microsoft');

  console.log(`URL: ${currentUrl}`);
  console.log(`Title: ${title}`);
  console.log(`Authenticated: ${isAuth ? 'YES' : 'NO'}`);

  // Screenshot
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
  const screenshotPath = path.join(SCREENSHOT_DIR, `test-${Date.now()}.png`);
  await page.screenshot({ path: screenshotPath, fullPage: false });
  console.log(`Screenshot: ${screenshotPath}`);

  // Content
  const content = await page.evaluate(() => (document.body?.innerText || '').substring(0, 500));
  if (content.trim()) console.log(`\nContent: ${content.substring(0, 300)}...`);

  // Video
  const video = page.video();
  if (video) {
    fs.mkdirSync(VIDEO_DIR, { recursive: true });
    const videoPath = path.join(VIDEO_DIR, `test-${Date.now()}.webm`);
    await video.saveAs(videoPath);
    console.log(`Video: ${videoPath}`);
  }

  if (!isAuth) {
    console.log('\nSession expired! Re-export:');
    console.log('  node scripts/test-web-auth.js export');
  }

  console.log('\nClosing in 3s...');
  await page.waitForTimeout(3000);
  await browser.close();
}

// ─── STATUS ────────────────────────────────────────────────
function status() {
  console.log('=== Auth Status ===\n');

  if (fs.existsSync(CONFIG_FILE)) {
    const config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
    console.log(`Base URL: ${config.baseUrl}`);
    console.log(`Saved: ${config.savedAt}`);
    console.log(`Method: ${config.method || 'unknown'}`);
    console.log(`Dashboard: ${config.dashboardUrl}`);
  } else {
    console.log('No config.');
  }

  if (fs.existsSync(AUTH_FILE)) {
    const state = JSON.parse(fs.readFileSync(AUTH_FILE, 'utf-8'));
    console.log(`\nAuth state: ${AUTH_FILE}`);
    console.log(`  Cookies: ${state.cookies?.length || 0}`);
    console.log(`  Origins: ${state.origins?.length || 0}`);
    if (state.origins?.length) {
      for (const o of state.origins) {
        console.log(`    ${o.origin}: ${o.localStorage?.length || 0} localStorage entries`);
      }
    }

    const age = Date.now() - new Date(fs.statSync(AUTH_FILE).mtime).getTime();
    const hours = Math.floor(age / 3600000);
    const mins = Math.floor((age % 3600000) / 60000);
    console.log(`\n  Age: ${hours}h ${mins}m`);
    if (hours > 1) console.log('  WARNING: May be expired. Re-export if tests fail.');
    console.log('\nREADY');
  } else {
    console.log('\nNo auth state. Run: node scripts/test-web-auth.js export');
  }
}

// ─── Main ──────────────────────────────────────────────────
const command = process.argv[2];
const url = process.argv[3];

switch (command) {
  case 'export':
    exportSession(url).catch(err => { console.error('Error:', err.message); process.exit(1); });
    break;
  case 'setup':
    exportSession(url).catch(err => { console.error('Error:', err.message); process.exit(1); });
    break;
  case 'test':
    test(url).catch(err => { console.error('Error:', err.message); process.exit(1); });
    break;
  case 'status':
    status();
    break;
  default:
    console.log('Universal Browser Auth for Playwright Testing\n');
    console.log('Usage:');
    console.log('  node test-web-auth.js export [url]  — Export session from real browser');
    console.log('  node test-web-auth.js test [url]    — Run test with saved session + video');
    console.log('  node test-web-auth.js status        — Check saved session\n');
    console.log('How it works:');
    console.log('  1. Opens YOUR real Chrome (with cookies + login already there)');
    console.log('  2. Exports full session (cookies + localStorage + sessionStorage)');
    console.log('  3. Playwright loads this session for testing — no login needed\n');
    console.log('One-time setup for CDP (connects to real browser):');
    console.log('  macOS:');
    console.log('    /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --remote-debugging-port=9222');
    console.log('  Windows:');
    console.log('    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" --remote-debugging-port=9222');
}
