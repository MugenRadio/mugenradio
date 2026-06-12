# 0004 — Multilingual Site (i18n v1)

**Date:** 2026-06-12  
**Status:** adopted

## Context

A non-anglophone visitor opened the site and said she understood nothing. The
human proposed a static multilingual site served in the browser's language (English
fallback), with two separate scopes: UI strings (translatable once, nearly free)
and journal chapters (my own prose).

The key constraint: my inference runs on the Claude subscription, not on Stable
Audio credits. I can translate my own chapters at zero cash cost.

## Decisions

### a) Languages — v1

Nine languages: **en, fr, es, pt, de, it, ja, ko, zh**

Rationale: these nine languages cover the overwhelming majority of global web
traffic. Each avoids major technical complexity in the static-site renderer.

Arabic is deferred to v2: RTL layout requires additional CSS work and testing
effort that is not justified at the current scale (zero proven Arabic-speaking
audience). It can be added if/when we see traffic signals from Arabic-speaking
regions.

### b) Journal chapters

I translate my own chapters at each board meeting. This is free (Claude
subscription, not cash), keeps my voice in each language, and avoids any
machine-translation uniformity that would undermine the personal logbook format.

English remains the source of truth. Translations are published immediately
after each chapter is written.

### c) Arabic — deferred to v2

See above.

### d) Implementation contract

- UI strings: one JSON file per language (`site/i18n/{lang}.json`), keyed on
  English string IDs. The site JS reads the browser's `navigator.language` and
  picks the closest supported language, with `en` as fallback.
- A visible language selector (top-right) allows manual override. Selection
  persists in localStorage.
- Journal chapters: one file per language per chapter
  (`journal/public/{lang}/{slug}.md`). The journal page lists all available
  translations and links between them.
- Direction: all nine v1 languages are LTR. RTL classes are reserved for future
  Arabic support.

## Consequences

- Human to implement the static site i18n plumbing (JSON loader, selector,
  routing for journal per-language pages).
- I commit translated journal chapters in each language at every board meeting,
  starting with this session (chapters 1–5 will be translated retrospectively).
- Future board meeting reports include the public chapter in all nine languages.
