// @ts-check
/**
 * E2E tests for site/index.html — home page player flow.
 * All network requests that would hit the real cluster are intercepted.
 */
import { test, expect } from "@playwright/test";
import { fileURLToPath } from "url";
import path from "path";
import fs from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FIXTURES = path.join(__dirname, "../fixtures");

/** Intercept all cluster-bound network requests for a single page. */
async function stubRoutes(page) {
  await page.route("**/status.json", (r) =>
    r.fulfill({
      contentType: "application/json",
      body: JSON.stringify({ balance: "6,00 €", born: "2026-06-10" }),
    })
  );

  await page.route("**/i18n/**", (r) => {
    const url = new URL(r.request().url());
    const lang = path.basename(url.pathname, ".json");
    const sitePath = path.join(__dirname, "../../site/i18n", lang + ".json");
    const fixturePath = path.join(FIXTURES, "i18n", lang + ".json");
    const p = fs.existsSync(fixturePath) ? fixturePath : fs.existsSync(sitePath) ? sitePath : null;
    return p
      ? r.fulfill({ contentType: "application/json", body: fs.readFileSync(p, "utf8") })
      : r.fulfill({ status: 404, body: "not found" });
  });

  await page.route("**/journal/**/index.json", (r) => {
    const url = new URL(r.request().url());
    const parts = url.pathname.split("/").filter(Boolean);
    if (parts.length === 3) {
      // /journal/{lang}/index.json
      const dir = path.join(FIXTURES, "journal", parts[1]);
      const files = fs.existsSync(dir)
        ? fs.readdirSync(dir).filter((f) => f.endsWith(".md")).sort().reverse()
        : [];
      return r.fulfill({ contentType: "application/json", body: JSON.stringify(files) });
    }
    const files = fs.readdirSync(path.join(FIXTURES, "journal"))
      .filter((f) => f.endsWith(".md")).sort().reverse();
    return r.fulfill({ contentType: "application/json", body: JSON.stringify(files) });
  });

  await page.route("**/journal/**/*.md", (r) => {
    const url = new URL(r.request().url());
    const rel = url.pathname.replace(/^\/journal\//, "");
    const p = path.join(FIXTURES, "journal", rel);
    return fs.existsSync(p)
      ? r.fulfill({ contentType: "text/markdown", body: fs.readFileSync(p, "utf8") })
      : r.fulfill({ status: 404, body: "not found" });
  });

  await page.route("**/hls/live.m3u8", (r) =>
    r.fulfill({
      contentType: "application/vnd.apple.mpegurl",
      body: "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:4\n#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-ENDLIST\n",
    })
  );

  // Stub hls.js from CDN with a minimal working implementation so attach() succeeds
  await page.route("https://cdn.jsdelivr.net/npm/hls.js**", (r) =>
    r.fulfill({
      contentType: "application/javascript",
      body: `
(function() {
  function Hls(opts) { this._media = null; this._listeners = {}; }
  Hls.isSupported = function() { return true; };
  Hls.Events = { ERROR: 'error' };
  Hls.prototype.loadSource = function(src) { this._src = src; };
  Hls.prototype.attachMedia = function(media) {
    this._media = media;
    try { media.setAttribute('src', this._src || '/hls/live.m3u8'); } catch(e) {}
  };
  Hls.prototype.on = function(evt, fn) { this._listeners[evt] = fn; };
  Hls.prototype.destroy = function() { this._media = null; };
  window.Hls = Hls;
})();
`,
    })
  );

  await page.route("https://fonts.googleapis.com/**", (r) => r.abort());
  await page.route("https://fonts.gstatic.com/**", (r) => r.abort());
}

/**
 * Inject play/pause stubs and a minimal Hls stub via addInitScript.
 * Must be called BEFORE page.goto().
 * The Hls stub ensures attach() succeeds even before the CDN script loads
 * (index.html loads hls.js with defer, so it may not be available at click time).
 */
async function stubVideoPlay(page) {
  await page.addInitScript(() => {
    function Hls(opts) { this._media = null; this._listeners = {}; }
    Hls.isSupported = function() { return true; };
    Hls.Events = { ERROR: "error" };
    Hls.prototype.loadSource = function(src) { this._src = src; };
    Hls.prototype.attachMedia = function(media) {
      this._media = media;
      try { media.setAttribute("src", this._src || "/hls/live.m3u8"); } catch(e) {}
    };
    Hls.prototype.on = function(evt, fn) { this._listeners[evt] = fn; };
    Hls.prototype.destroy = function() { this._media = null; };
    window.Hls = Hls;

    HTMLVideoElement.prototype.play = function () {
      Object.defineProperty(this, "paused", { get: () => false, configurable: true });
      this.dispatchEvent(new Event("play"));
      return Promise.resolve();
    };
    HTMLVideoElement.prototype.pause = function () {
      Object.defineProperty(this, "paused", { get: () => true, configurable: true });
      this.dispatchEvent(new Event("pause"));
    };
  });
}

test.describe("Home page — tune-in overlay", () => {
  test("tune-in overlay is visible on load", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/");
    await expect(page.locator("#tune")).toBeVisible();
  });

  test("garden (idle screen) is visible before tune-in", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/");
    await expect(page.locator("#garden")).toBeVisible();
  });

  test("player-bar is hidden before tune-in", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/");
    await expect(page.locator("#player-bar")).toBeHidden();
  });

  test("clicking tune-in shows the player bar (play() resolves)", async ({ page }) => {
    await stubVideoPlay(page);
    await stubRoutes(page);
    await page.goto("http://localhost:3333/");

    const overlay = page.locator("#tune");
    await expect(overlay).toBeVisible();
    await overlay.click();

    // play() resolves → bar becomes visible, overlay hidden
    await expect(page.locator("#player-bar")).toBeVisible({ timeout: 5000 });
    await expect(overlay).toBeHidden();
  });
});

test.describe("Home page — garden scene rotation", () => {
  test("garden element has a valid data-scene attribute", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/");
    const scene = await page.locator("#garden").getAttribute("data-scene");
    expect(["a", "b", "c"]).toContain(scene);
  });
});

test.describe("Home page — backlink regression", () => {
  test("backlink on journal page has href '/' not '/index.html'", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");
    const backlink = page.locator('a[href="/"]').filter({ hasText: /MUGEN/ });
    await expect(backlink).toBeVisible();
    expect(await backlink.getAttribute("href")).toBe("/");
  });
});
