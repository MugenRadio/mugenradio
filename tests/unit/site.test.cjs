// Unit tests for site.js pure helpers — run with: node --test tests/unit/site.test.cjs
// Uses only Node.js built-in node:test and node:assert. No DOM, no browser.
// File is .cjs so it loads as CommonJS even in an "type":"module" package.
// Imports site.js via site-helpers.cjs (a vm-based shim) to work around the
// Node 22 ESM-CJS bridge behaviour where module.exports = {} is ignored for
// .js files inside a "type":"module" package.

"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const path = require("node:path");

const {
  gardenSceneAt,
  detectLang,
  savedVolume,
  dateLabel,
  GARDEN_CYCLE,
  GARDEN_EDGES,
} = require(path.join(__dirname, "site-helpers.cjs"));

// ===== gardenSceneAt =====

test("gardenSceneAt: 0 → a (start of cycle)", () => {
  assert.equal(gardenSceneAt(0), "a");
});

test("gardenSceneAt: 1 → a (well inside scene a)", () => {
  assert.equal(gardenSceneAt(1), "a");
});

test("gardenSceneAt: 209 → a (last second before b)", () => {
  assert.equal(gardenSceneAt(209), "a");
});

test("gardenSceneAt: 210 → b (first second of scene b)", () => {
  assert.equal(gardenSceneAt(210), "b");
});

test("gardenSceneAt: 464 → b (last second before c)", () => {
  assert.equal(gardenSceneAt(464), "b");
});

test("gardenSceneAt: 465 → c (first second of scene c)", () => {
  assert.equal(gardenSceneAt(465), "c");
});

test("gardenSceneAt: 719 → c (last second before final crossfade)", () => {
  assert.equal(gardenSceneAt(719), "c");
});

test("gardenSceneAt: 720 → a (crossfading back to a, 720-764)", () => {
  assert.equal(gardenSceneAt(720), "a");
});

test("gardenSceneAt: 764 → a (last second of cycle)", () => {
  assert.equal(gardenSceneAt(764), "a");
});

test("gardenSceneAt: GARDEN_CYCLE (765) wraps to 0 → a", () => {
  assert.equal(gardenSceneAt(GARDEN_CYCLE), "a");
});

test("gardenSceneAt: GARDEN_CYCLE + 210 wraps → b", () => {
  assert.equal(gardenSceneAt(GARDEN_CYCLE + 210), "b");
});

test("gardenSceneAt: negative value wraps correctly (-1 → last second → a)", () => {
  // -1 mod 765 = 764, which is in the 720-765 range → a
  assert.equal(gardenSceneAt(-1), "a");
});

test("gardenSceneAt: -210 wraps to 555 (inside c range 465-719) → c", () => {
  // -210 mod 765 = 555, inside [465, 720) → c
  assert.equal(gardenSceneAt(-210), "c");
});

test("gardenSceneAt: large positive value wraps correctly", () => {
  // 765 * 1000 + 100 → 100 → a
  assert.equal(gardenSceneAt(GARDEN_CYCLE * 1000 + 100), "a");
});

test("gardenSceneAt: GARDEN_EDGES values match expected breakpoints", () => {
  assert.deepEqual(GARDEN_EDGES, [210, 465, 720]);
});

// ===== detectLang =====

test("detectLang: exact match 'fr' in prefs", () => {
  assert.equal(detectLang(["fr"], null), "fr");
});

test("detectLang: regional variant fr-CA → fr", () => {
  assert.equal(detectLang(["fr-CA"], null), "fr");
});

test("detectLang: regional variant pt-BR → pt", () => {
  assert.equal(detectLang(["pt-BR"], null), "pt");
});

test("detectLang: unknown language falls back to en", () => {
  assert.equal(detectLang(["xx", "zz"], null), "en");
});

test("detectLang: empty prefs falls back to en", () => {
  assert.equal(detectLang([], null), "en");
});

test("detectLang: savedLang takes priority over prefs", () => {
  assert.equal(detectLang(["de"], "fr"), "fr");
});

test("detectLang: invalid savedLang is ignored, prefs used", () => {
  assert.equal(detectLang(["de"], "xx"), "de");
});

test("detectLang: case insensitive (FR → fr)", () => {
  assert.equal(detectLang(["FR"], null), "fr");
});

test("detectLang: first supported lang in list is picked", () => {
  assert.equal(detectLang(["xx", "zz", "ja", "ko"], null), "ja");
});

test("detectLang: zh is supported", () => {
  assert.equal(detectLang(["zh-TW"], null), "zh");
});

// ===== savedVolume =====

test("savedVolume: null raw → default 0.8", () => {
  assert.equal(savedVolume(null), 0.8);
});

test("savedVolume: undefined raw → default 0.8", () => {
  assert.equal(savedVolume(undefined), 0.8);
});

test("savedVolume: 'NaN' string → default 0.8", () => {
  assert.equal(savedVolume("NaN"), 0.8);
});

test("savedVolume: empty string → default 0.8", () => {
  assert.equal(savedVolume(""), 0.8);
});

test("savedVolume: '0.5' → 0.5", () => {
  assert.equal(savedVolume("0.5"), 0.5);
});

test("savedVolume: '0' → 0 (valid)", () => {
  assert.equal(savedVolume("0"), 0);
});

test("savedVolume: '1' → 1 (max)", () => {
  assert.equal(savedVolume("1"), 1);
});

test("savedVolume: '0.75' → 0.75", () => {
  assert.equal(savedVolume("0.75"), 0.75);
});

test("savedVolume: 'Infinity' → default 0.8 (not finite)", () => {
  assert.equal(savedVolume("Infinity"), 0.8);
});

// ===== dateLabel =====

test("dateLabel: known date file → formatted date in en-GB", () => {
  const result = dateLabel("2026-06-12-first-breath.md", "en");
  // en-GB format: "12 June 2026"
  assert.equal(result, "12 June 2026");
});

test("dateLabel: known date file → formatted date in fr", () => {
  const result = dateLabel("2026-06-12-first-breath.md", "fr");
  // fr format includes year 2026 and day 12
  assert.ok(result.includes("2026"), `Expected year in: ${result}`);
  assert.ok(result.includes("12"), `Expected day in: ${result}`);
});

test("dateLabel: file containing 'comptes' → 'the books' (default strings)", () => {
  assert.equal(dateLabel("comptes-2026.md", "en", {}), "the books");
});

test("dateLabel: file containing 'comptes' → translated when strings provided", () => {
  const strings = { "journal.books": "les comptes" };
  assert.equal(dateLabel("comptes-2026.md", "fr", strings), "les comptes");
});

test("dateLabel: no date prefix and no comptes → humanised filename", () => {
  const result = dateLabel("some-slug-file.md", "en");
  assert.equal(result, "some slug file");
});

test("dateLabel: underscores also replaced with spaces", () => {
  const result = dateLabel("some_slug_file.md", "en");
  assert.equal(result, "some slug file");
});

test("dateLabel: Jan 1 2026 parsed correctly", () => {
  const result = dateLabel("2026-01-01-new-year.md", "en");
  assert.equal(result, "1 January 2026");
});

test("dateLabel: date uses local Date constructor (no timezone shift)", () => {
  // new Date(2026, 5, 12) is guaranteed midnight local time → no off-by-one
  const result = dateLabel("2026-06-12-test.md", "en");
  assert.equal(result, "12 June 2026");
});
