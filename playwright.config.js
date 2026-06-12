// @ts-check
import { defineConfig, devices } from "@playwright/test";
import { fileURLToPath } from "url";
import path from "path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  testDir: "./tests/e2e",
  timeout: 30_000,
  // Each test file gets its own worker; E2E tests are sequential within a file.
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? "github" : "list",

  // Global setup: start a static server serving site/ on port 3333.
  // The fixture data (journal, i18n) is served by Playwright route interception
  // inside each test, so only the static site files need a real server.
  webServer: {
    command: `python3 -m http.server 3333 --directory ${path.join(__dirname, "site")}`,
    url: "http://localhost:3333/",
    reuseExistingServer: !process.env.CI,
    stdout: "ignore",
    stderr: "ignore",
  },

  use: {
    baseURL: "http://localhost:3333",
    // Capture screenshots and traces on failure for debugging
    screenshot: "only-on-failure",
    trace: "on-first-retry",
  },

  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      // Firefox — the double-attach bug was Firefox-specific
      name: "firefox",
      use: { ...devices["Desktop Firefox"] },
    },
  ],
});
