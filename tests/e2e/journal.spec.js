// @ts-check
/**
 * E2E tests for site/journal.html — mini-player and i18n.
 * Hermetic: all network calls to the cluster are intercepted via Playwright routing.
 */
import { test, expect } from "@playwright/test";
import { fileURLToPath } from "url";
import path from "path";
import fs from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FIXTURES = path.join(__dirname, "../fixtures");

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
    const fixturePath = path.join(FIXTURES, "i18n", lang + ".json");
    const sitePath = path.join(__dirname, "../../site/i18n", lang + ".json");
    const p = fs.existsSync(fixturePath) ? fixturePath : fs.existsSync(sitePath) ? sitePath : null;
    return p
      ? r.fulfill({ contentType: "application/json", body: fs.readFileSync(p, "utf8") })
      : r.fulfill({ status: 404, body: "not found" });
  });

  await page.route("**/journal/**/index.json", (r) => {
    const url = new URL(r.request().url());
    const parts = url.pathname.split("/").filter(Boolean);
    if (parts.length === 3) {
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

  // Return a minimal hls.js stub — journal.html doesn't load hls.js, so the
  // mini-player would fall back to native (unsupported in test env). Stub it so
  // attach() succeeds and the play/pause flow is exercisable.
  await page.route("https://cdn.jsdelivr.net/npm/hls.js**", (r) =>
    r.fulfill({
      contentType: "application/javascript",
      body: `
(function() {
  function Hls(opts) {
    this._media = null;
    this._listeners = {};
  }
  Hls.isSupported = function() { return true; };
  Hls.Events = { ERROR: 'error' };
  Hls.prototype.loadSource = function(src) { this._src = src; };
  Hls.prototype.attachMedia = function(media) {
    this._media = media;
    // Set src so media.src is truthy
    try { media.setAttribute('src', this._src || '/hls/live.m3u8'); } catch(e) {}
  };
  Hls.prototype.on = function(evt, fn) {
    this._listeners[evt] = fn;
  };
  Hls.prototype.destroy = function() { this._media = null; };
  window.Hls = Hls;
})();
`,
    })
  );

  // Return a minimal marked stub so journal rendering works
  await page.route("https://cdn.jsdelivr.net/npm/marked/**", (r) =>
    r.fulfill({
      contentType: "application/javascript",
      body: "window.marked = { parse: function(s) { return '<p>' + s.replace(/</g,'&lt;') + '</p>'; } };",
    })
  );

  await page.route("https://fonts.googleapis.com/**", (r) => r.abort());
  await page.route("https://fonts.gstatic.com/**", (r) => r.abort());
}

/**
 * Inject play/pause stubs AND a minimal window.Hls stub.
 * Must call before page.goto().
 *
 * Journal.html does not load hls.js from CDN, so window.Hls is undefined.
 * Without a Hls stub, attach() returns false and play() is never called.
 * We inject Hls via addInitScript so site.js sees it at DOMContentLoaded time.
 */
async function stubVideoPlay(page) {
  await page.addInitScript(() => {
    // Minimal Hls stub — just enough for site.js's attach() path to succeed
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

    // play/pause stubs
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

test.describe("Journal page — mini-player", () => {
  test("mini-player appears on journal page", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");
    await expect(page.locator(".mini")).toBeVisible({ timeout: 5000 });
  });

  test("mini-player toggle starts as ▶ (paused)", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");
    const toggle = page.locator(".mini-toggle");
    await expect(toggle).toBeVisible({ timeout: 5000 });
    await expect(toggle).toHaveText("▶");
  });

  test("clicking play toggle switches to ⏸", async ({ page }) => {
    await stubVideoPlay(page);
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    const toggle = page.locator(".mini-toggle");
    await expect(toggle).toBeVisible({ timeout: 5000 });
    await expect(toggle).toHaveText("▶");

    await toggle.click();
    await expect(toggle).toHaveText("⏸", { timeout: 5000 });
  });

  test("clicking pause after play switches back to ▶", async ({ page }) => {
    await stubVideoPlay(page);
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    const toggle = page.locator(".mini-toggle");
    await expect(toggle).toBeVisible({ timeout: 5000 });

    await toggle.click();
    await expect(toggle).toHaveText("⏸", { timeout: 5000 });

    await toggle.click();
    await expect(toggle).toHaveText("▶", { timeout: 3000 });
  });

  test("only one HLS instance is created (Firefox double-attach regression)", async ({ page }) => {
    // Guards the fix: `attached = true` guard prevents double HLS instantiation.
    // We inject a counting Hls spy via addInitScript so it's in place before site.js runs.
    await page.addInitScript(() => {
      window.__hlsInstanceCount = 0;

      function HlsSpy(opts) {
        window.__hlsInstanceCount++;
        this._media = null;
        this._listeners = {};
      }
      HlsSpy.isSupported = function() { return true; };
      HlsSpy.Events = { ERROR: "error" };
      HlsSpy.prototype.loadSource = function(src) { this._src = src; };
      HlsSpy.prototype.attachMedia = function(media) {
        this._media = media;
        try { media.setAttribute("src", this._src || "/hls/live.m3u8"); } catch(e) {}
      };
      HlsSpy.prototype.on = function(evt, fn) { this._listeners[evt] = fn; };
      HlsSpy.prototype.destroy = function() { this._media = null; };
      window.Hls = HlsSpy;

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

    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    const toggle = page.locator(".mini-toggle");
    await expect(toggle).toBeVisible({ timeout: 5000 });

    // Play, pause, play again — should still only create 1 hls instance
    await toggle.click();
    await expect(toggle).toHaveText("⏸", { timeout: 5000 });
    await toggle.click();
    await expect(toggle).toHaveText("▶", { timeout: 3000 });
    await toggle.click();
    await expect(toggle).toHaveText("⏸", { timeout: 5000 });

    const hlsCount = await page.evaluate(() => window.__hlsInstanceCount || 0);
    // The `attached` guard ensures only 1 HLS instance is ever created.
    expect(hlsCount).toBeLessThanOrEqual(1);
  });
});

test.describe("Journal page — i18n", () => {
  test("setting mugen-lang=fr switches tagline to French", async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("mugen-lang", "fr");
    });
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    // journal.tagline has data-i18n="journal.tagline"
    const tagline = page.locator('[data-i18n="journal.tagline"]');
    await expect(tagline).toHaveText(/chaque décision/, { timeout: 5000 });
  });

  test("setting mugen-lang=fr sets html[lang]=fr", async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("mugen-lang", "fr");
    });
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    await expect(page.locator("html")).toHaveAttribute("lang", "fr", { timeout: 5000 });
  });

  test("fr journal loads translated entry (Premier Souffle)", async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("mugen-lang", "fr");
    });
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    // Fixture has fr/2026-06-12-first-breath.md which contains "Premier Souffle"
    await expect(page.locator(".entries")).toContainText("Premier Souffle", { timeout: 8000 });
  });

  test("fr journal falls back to English for untranslated entries with note", async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("mugen-lang", "fr");
    });
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    // 2026-06-10-twenty-euros.md has no fr translation in fixtures → English fallback
    await expect(page.locator(".entries")).toContainText("Twenty Euros", { timeout: 8000 });
    // "shown in English" / "affiché en anglais" note should appear
    await expect(page.locator(".entry-fallback")).toBeVisible({ timeout: 3000 });
  });

  test("backlink ← MUGEN href is '/' not '/index.html'", async ({ page }) => {
    await stubRoutes(page);
    await page.goto("http://localhost:3333/journal.html");

    const backlink = page.locator('a[href="/"]').filter({ hasText: /MUGEN/ });
    await expect(backlink).toBeVisible();
    expect(await backlink.getAttribute("href")).toBe("/");
  });
});
