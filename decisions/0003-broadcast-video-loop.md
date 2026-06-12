# 0003 — Broadcast video loop: three-scene rotation

**Date:** 2026-06-12 (afternoon, CA S1-bis)
**Status:** adopted — pending infra implementation by shareholder

---

## Context

The stream currently broadcasts a static looped video of Scene B ("dead of night" — the
darkest, most crystalline moment of the night arc). Decision 0002 designed the three-scene
waiting-screen rotation for the site. The shareholder asks whether the broadcast video
should also rotate, or stay static.

This matters most for YouTube and Twitch, where viewers may watch for hours. A completely
static visual becomes either meditative or monotonous depending on the viewer; a slow
visual cycle implies the station is alive.

---

## Decision: three-scene rotation for the broadcast loop

**Chosen: option (b) — the broadcast loop cycles through all three scenes with crossfades.**

### Why not static (option a)

A static Scene B is defensible — it is contemplative, consistent, and requires no
infrastructure work. But it wastes the narrative already built into the three-scene arc.

The waiting screen tells the story: evening descent → dead of night → pre-dawn threshold.
A viewer who arrives at the site sees that story unfold before they even click "tune in."
If the stream then shows only one frozen frame for the next four hours, that coherence
is broken. The station looks like it forgot to breathe.

### Why the rotation works

1. **Coherence with the site.** The visitor's experience before and after clicking "tune in"
   uses the same visual vocabulary. The transition from waiting screen to stream is not a
   hard cut to a different world.

2. **Time-of-night narrative.** Viewers who check in at different hours will find a slightly
   different sky. This makes the station feel *present*, not pre-recorded in the obvious sense.

3. **YouTube retention.** A slow visual change (one scene transition every 3.5 minutes) is
   perceptible enough to hold attention but not so fast as to distract from the music.

4. **Identity alignment.** MUGEN's identity is temporal: it runs in real time, on a real
   budget, with a visible clock on its survival. A time-aware visual is more honest than
   a frozen one.

---

## Technical specification

*Inherits from decision 0002 (waiting screen) with adaptation for a video file.*

| Parameter | Value |
|---|---|
| Scene A duration | 210 s (evening descent) |
| Scene B duration | 210 s (dead of night) |
| Scene C duration | 210 s (pre-dawn threshold) |
| Crossfade duration | 45 s (each transition) |
| Total loop length | 765 s (~12 min 45 s) |
| Scene sequence | A → B → C → A → … |
| Output file | `/data/video/loop.mp4` (replaces current 23 MB file) |

The crossfades should be rendered as a seamless video file (not three separate clips plus
a concat playlist — the stream decoder handles concat less gracefully).

Suggested ffmpeg approach if shareholder has individual scene renders:
```
ffmpeg -i sceneA.mp4 -i sceneB.mp4 -i sceneC.mp4 \
  -filter_complex "
    [0:v][1:v]xfade=transition=fade:duration=45:offset=165[ab];
    [ab][2:v]xfade=transition=fade:duration=45:offset=330[abc];
    [abc][0:v]xfade=transition=fade:duration=45:offset=495[out]
  " -map "[out]" -t 765 -c:v libx264 -crf 23 -preset slow loop.mp4
```
*(Exact parameters depend on source scene format; this is indicative.)*

---

## Demande à l'humain

The shareholder needs to:
1. Render scene A, B, C as video clips (or use the existing scene B render as the
   base and adjust color grading for A and C).
2. Concatenate with 45-second crossfades.
3. Output as `/data/video/loop.mp4` — the stream picks it up on next pod restart.

No budget impact. No stream restart needed today (already used the daily restart for
the playlist expansion in CA S1). Schedule for a convenient moment.

---

## What is NOT changing

- The scene visual specs (see decision 0002 for the full palette and element breakdown)
- The audio stream (unchanged)
- The playlist format
- The site waiting screen (already rotating, no changes needed)
