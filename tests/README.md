# Test suite

Three layers, zero fake tests.

## Prerequisites

- **bats** — `sudo apt install bats` / `brew install bats-core`
- **Node.js 22+** — built-in `node:test` used, no extra deps
- **shellcheck** — `sudo apt install shellcheck`
- **Playwright** — `npm install` then `npx playwright install --with-deps chromium firefox`

## Run all

```sh
npm test
```

## Run individual layers

```sh
# Shell unit tests (bats)
npm run test:shell

# shellcheck on every agent script
npm run test:shellcheck

# JS unit tests (node:test, no DOM)
npm run test:unit

# E2E (Playwright, chromium + firefox)
npm run test:e2e

# E2E single browser
npm run test:e2e:chromium
npm run test:e2e:firefox
```

## What each layer covers

### `tests/shell/` — bats unit tests

| File | What it tests |
|---|---|
| `wake_budget.bats` | awk sum of column 3 in api_usage.csv; threshold gate (exit code); integration |
| `generate_track_dur.bats` | DUR validation: rejects floats/empty/negative/letters, accepts integers, caps >190 |
| `publish_www.bats` | Full publish run on a fixture tree: index.json sort order, per-lang indexes, status.json balance, site/ copy |
| `playlist_invariant.bats` | ffconcat invariants: first line header, last line self-reference, relative paths only |

### `tests/unit/` — JS unit tests (node:test)

File: `site.test.js` — 42 tests covering:

- `gardenSceneAt`: all scene boundaries (0, 209/210, 464/465, 719/720, 764, 765 wrap, negative, large)
- `detectLang`: exact match, regional variants (fr-CA→fr, pt-BR→pt), unknown→en, savedLang priority, case insensitive
- `savedVolume`: null/undefined/NaN/empty→0.8, valid floats, Infinity→0.8
- `dateLabel`: known date formatting (en-GB, fr), "comptes" → "the books", custom strings, fallback slug

### `tests/e2e/` — Playwright (chromium + firefox)

| File | What it tests |
|---|---|
| `home.spec.js` | Overlay visible on load; garden visible; bar hidden; click tune-in → bar shows; garden has data-scene; backlink href regression |
| `journal.spec.js` | Mini-player appears; starts as ▶; click play → ⏸; click pause → ▶; single HLS attach (Firefox double-attach regression); fr i18n switches strings; html[lang]=fr; fr entries load; English fallback + note shown; backlink href "/" regression |

All E2E tests are hermetic: `/hls/`, `/status.json`, `/i18n/`, `/journal/` are intercepted via Playwright routing. The static server serves only `site/`. No network access to the live cluster.

## site.js refactor

The IIFE is unchanged for browsers. Pure helpers (`gardenSceneAt`, `detectLang`, `savedVolume`, `dateLabel`) are extracted to module-level functions before the IIFE, guarded by `typeof module !== 'undefined'` for `module.exports`. The IIFE is wrapped in `if (typeof document !== 'undefined')` so it silently skips in Node.js without throwing.
