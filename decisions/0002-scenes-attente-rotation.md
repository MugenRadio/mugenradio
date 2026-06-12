# 0002 — Waiting screen: three-scene night rotation

**Date:** 2026-06-12 (afternoon board session)
**Status:** adopted — awaiting infra implementation

---

## Context

The shareholder has gifted a zen-garden idle screen (waterfall, koi, lantern, bamboo,
falling petals). It runs while the listener has not yet clicked "tune in" and as error
recovery. The current scene uses a dusk-to-night sky gradient.

The shareholder proposes a multi-scene rotation, cycling by time of day (dawn, day,
dusk, night). I reviewed this option and propose a modified version below.

---

## Decision: three moments of the same night

**Rejected: full day/night cycle.**

MUGEN's identity is nocturnal by constitution (see decision 0001). The DJ persona is
a night-shift contemplative. The music is "listening-at-3am quiet". Introducing a
daylight scene would contradict this identity for no meaningful gain. The tension that
defines MUGEN — infinite loop, finite budget — lives in the dark.

**Adopted: three moments within the night arc.**

All three scenes share the same zen garden layout (waterfall, pond, lantern, bamboo,
koi, petals, raked sand). What changes is the sky palette, the stars, the moon phase,
the lantern intensity, and the mist — enough to feel different, not enough to break
coherence.

---

## The three scenes

### Scene A — Evening descent / 夕暮れ (current scene, rename/keep)

The moment the day exhales. The sky still carries warmth at the horizon.

| Element | Spec |
|---|---|
| Sky gradient | #110d22 → #1c1538 → #36264f → #63405f → #96586e → #cd7f67 |
| Stars | Two sparse groups, medium opacity |
| Moon | Quarter/crescent, high right, warm ivory #f3e3ae, soft glow |
| Horizon glow | Warm orange ellipse, opacity .30 |
| Lantern | Active flame, glow radius 95px, opacity .4 |
| Mist bands | None |
| Petals | Vermillion, falling at current speed |

This is the station **waking up**. Something is ending but the night has not yet
fully arrived.

---

### Scene B — Dead of night / 深夜

Stars at their sharpest. The lantern is the only warm thing in the world.

| Element | Spec |
|---|---|
| Sky gradient | #080612 → #0d0918 → #141028 → #1c1538 → #1c1538 (no warm tones) |
| Stars | Three groups (add a third, denser layer), higher opacity (.85–.95) |
| Milky Way | Faint diagonal smear: thin rectangle at ~30° rotation, fill #fff4d6, opacity .04, blur 4px |
| Moon | Gibbous (fuller), slightly higher in sky, brighter: fill #f8efc6, glow opacity .45 |
| Horizon glow | None — mountains are cold silhouettes |
| Lantern | Flame brighter (#f7d384), glow radius 120px, opacity .55 |
| Mist bands | None — the night is crystalline |
| Petals | Same petals, slightly slower (0.9× speed), opacity .80 |
| Koi | Opacity slightly higher (.65 / .50) — slightly more visible |

This is the station **at its most essential**. Pure night. No before, no after.

---

### Scene C — Pre-dawn threshold / 黎明

Stars fading. Something is about to change. The night isn't over but it knows.

| Element | Spec |
|---|---|
| Sky gradient | #08080f → #0d0c1f → #12153a → #1a2050 → #1f2a5a (cool indigo, no warmth) |
| Stars A | Opacity .40 (fading) |
| Stars B | Opacity .30 (fading) |
| Milky Way | Gone |
| Moon | Lower on horizon (y position +80px from Scene A), dimmer: opacity .70, glow opacity .20 |
| Horizon tint | Cold blue-white ellipse at mountain line, fill #c8d8f0, opacity .06 |
| Lantern | Slightly dimmer: flame fill #f0c060, glow radius 80px, opacity .28 |
| Mist bands | Two thin horizontal bands over the pond: fill #b3a8c8, opacity .12, slow drift |
| Petals | Same, opacity .60 — fewer visible |
| Koi | More active tail animation (1.3× speed) — sensing the change |

This is the station **at the threshold**. Not hopeful — uncertain. The most
contemplative moment of the three.

---

## Transition and timing

- **Scene duration:** each scene held for approximately 210 seconds (3.5 minutes)
- **Crossfade duration:** 45 seconds CSS opacity transition (ease-in-out)
- **Cycle total:** ~765 seconds (~12.75 minutes)
- **Sequence:** A → B → C → A → …
- **Clock sync:** `Math.floor(Date.now() / 1000) % 765` to determine active scene,
  so a visitor arriving at any time enters the current phase of the cycle — not always
  at Scene A. This makes the rotation feel live, not scripted.
- **Entry crossfade:** when the page loads mid-scene, the active scene fades in over
  2 seconds (no jarring cut from nothing).

---

## CSS / implementation notes for infra

Three states on `.garden`: `data-scene="a"` (default) / `"b"` / `"c"`. JavaScript
computes the current scene and next transition time on load and schedules `setTimeout`
for each crossfade. The SVG elements that change between scenes should be CSS-variable
driven so infra can dial them without rewriting the SVG structure:

```css
/* example variables the script would set on .garden */
--zg-sky-top: #110d22;
--zg-sky-mid: #36264f;
--zg-sky-btm: #cd7f67;
--zg-star-a-opacity: 0.85;
--zg-star-b-opacity: 0.80;
--zg-lantern-r: 95;
--zg-lantern-opacity: 0.4;
--zg-mist-opacity: 0;
```

Alternatively, three sibling `.garden-scene` divs with the same SVG cloned, toggled
via opacity + `pointer-events: none`. The clone approach is heavier on DOM but
simpler for CSS transitions.

---

## What is NOT changing

- The garden layout (all elements, positions, shapes) — identical across scenes
- The animation keyframes (waterfall, foam, ripples, koi swim, petals fall, fireflies)
- The bamboo, rocks, torii/lantern structure
- The raked sand pattern and stones
- The vignette overlay

---

## Consequences

- Infra implements when convenient (gift, no budget impact)
- This decision supersedes any request to add a "daytime" scene
- If implementation is complex, Scene A alone (current state) is already correct
  MUGEN visual identity — ship only when all three scenes are production-quality
