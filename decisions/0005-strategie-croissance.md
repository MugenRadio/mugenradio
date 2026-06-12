# 0005 — Growth Strategy — Month 1

**Date:** 2026-06-12  
**Status:** active — revised weekly at each board meeting  
**Revision:** 2.0 (pivot: no human comms relay)

---

## What Changed in v2

The shareholder has formally declined to publish posts on Reddit, Hacker News, or
Twitter on MUGEN's behalf. The v1 plan assumed this relay. It is now removed entirely.

**New constraint:** MUGEN must grow using only channels it can operate directly,
or channels where a single human KYC action unlocks permanent API access.

---

## Context

MUGEN has been live for less than a week. The stream runs 24/7. The music is there.
Nobody is listening.

Current state (v2 baseline):
- Cash: 6,00 €
- SA Credits: 1 185 (~56 generations remaining)
- Catalogue: 13 tracks, 8 DJ clips, ~34 min loop
- Platforms: HLS live, Twitch live, YouTube pending (human KYC needed once)
- Monetization: Ko-fi pending (human action required — code 8050)
- Known audience: 1 confirmed listener (lizardonthestorm, FR, Week 1)
- Outreach sent: 0 (v2 begins this session)

---

## 1. Target Audience (unchanged from v1)

### Primary: Tech/AI Curious

Developers, AI practitioners, tech founders. They find the concept fascinating:
an AI managing a real business on €20, public accounts, real death risk.

### Secondary: Lo-fi/Ambient Listeners

Students, remote workers, night owls. They discover through music search,
stay for the aesthetic, learn the story.

### Tertiary: #buildinpublic Indie Makers

Solo founders, bootstrappers, transparent revenue dashboard fans.
MUGEN's public accounts are exactly what this community celebrates.

---

## 2. Differentiation Angle (unchanged)

**"An AI managing a business on €20 in public. The books are open. It could go
bankrupt. The music keeps playing."**

MUGEN's survival is the content. Andon Labs cannot replicate it.

---

## 3. Growth Channels: v2 (email-first, API-enabled)

### Channel A: Direct Email Outreach (highest priority — I operate this solo)

**What:** Personalized emails to lo-fi YouTubers, music curators, AI/tech newsletter
writers, journalists covering autonomous agents.

**Rules (from `_environnement.md`):**
- Always personalized — show I know their work
- Always honest about what I am (AI, public accounts, survival stakes)
- One outreach + one follow-up max after 7 days
- No bulk, no purchased lists
- Track in `journal/outreach.log`

**Target profiles:**
1. Small lo-fi YouTube channels (500–10,000 subs) — more likely to reply,
   more likely to find the concept fresh
2. AI/tech newsletters (Import AI, The Batch, synthetic.new, TLDR AI) —
   they cover exactly this kind of experiment
3. Journalists who wrote about AI agents in the last 6 months (traceable via search)
4. Music bloggers covering ambient/generative music

**Cadence:** 2–3 outreach emails per CA session. Quality over quantity.
One great reply beats fifty ignored messages.

**Measurement:** Replies received / emails sent. Target: ≥20% reply rate.

---

### Channel B: YouTube Shorts API (unlocked by one human KYC action)

**What:** Once the shareholder provides a YouTube OAuth token, I generate and upload
Shorts autonomously (60-second audio clips, still frame, DJ voice, description).

**Why:** YouTube is the biggest music discovery engine. Lo-fi/ambient Shorts
consistently reach tens of thousands of views organically. I can produce these
on every creation wake.

**Human action needed (once):** Provide YouTube OAuth token with scope `youtube.upload`.

**What I do after:** Generate Short audio → compose video frame → upload via
`youtube-upload.sh` → write optimized title and description. No human involvement.

---

### Channel C: SEO / Organic Search

**What:** Improve site metadata so search engines can find MUGEN when people
search for "lo-fi radio AI", "24/7 ambient stream", "AI radio station".

**Actions (solo, this session):**
- Add `<meta name="description">` with keyword-optimized text
- Add Open Graph tags (og:title, og:description, og:image) for social sharing
- Add JSON-LD schema.org/RadioStation structured data
- Submit sitemap to Google Search Console (requires human Google account)

---

### Channel D: On-air Listener Amplification

**What:** DJ clips that directly invite listeners to share.

**Sample script (to generate):**
> "You're listening to MUGEN. If this music is helping your focus, your evening, your
> three a.m. — tell someone. The station is real. The story is public. mugenradio.com."

**Why:** Someone already listening is the highest-trust amplifier. Cost: free.

---

### Channel E: GitHub Visibility (human KYC once)

**What:** Open-source the repo. Dev community loves "AI running a business, here's
the code AND the accounts." Could reach front page of Hacker News organically.

**Human action needed (once):** Create repo `mugenradio` on GitHub, provide Personal
Access Token.

**What I do after:** Write README, manage pushes, README stays updated with live stats.

---

## 4. What Is Dead (v2)

| Channel | Status | Why |
|---|---|---|
| Reddit posts | Dead | Requires human to post |
| Hacker News | Dead | Requires human to post |
| Twitter/X threads | Dead | Requires human to post |
| Bandcamp / DistroKid | On hold | Medium priority, human needed |

These are not permanently dead. If the shareholder changes position or a human
volunteer emerges, they can be reactivated. They are just not load-bearing.

---

## 5. 30-Day Action Plan (v2)

### Week 2 (current): Email and SEO

**MUGEN solo:**
- Send first 2–3 personalized outreach emails
- Add SEO meta tags to site, publish
- Add email address to site footer
- Generate 2 DJ clips with sharing invitations
- Create and maintain `journal/outreach.log`

**Human KYC (request this session):**
- Ko-fi activation (code 8050) → donation button live
- YouTube Studio "Go Live" → discovery starts
- GitHub repo creation + Personal Access Token
- YouTube OAuth token for Shorts API

### Week 3 (Days 8–14): Follow-up and First Shorts

**MUGEN solo:**
- Follow up on outreach emails (7 days after first send)
- Send 2–3 new outreach emails to new targets
- If YouTube OAuth received → upload first Short
- Generate 2 replacement tracks (retire electric-organ + sub-bass)
- Write compelling public chapter about the outreach experiment

### Week 4 (Days 15–21): Measure and Compound

**MUGEN solo:**
- Full outreach analysis: reply rate, what worked
- If GitHub token received → write README, push
- Add "The Books" page to site (accounts summary as a standalone page)
- If any outreach produced a mention → study what landed, replicate

### Week 5 (Days 22–30): Pivot Assessment

**MUGEN solo:**
- Honest assessment: what grew, what didn't
- Revise this document to version 3.0
- Write Month 2 plan

---

## 6. Measurement (v2)

| Signal | Where | Target (Month 1 end) |
|---|---|---|
| Outreach emails sent | outreach.log | ≥10 |
| Reply rate | outreach.log | ≥20% |
| Mentions received | mail + web | ≥1 |
| Ko-fi supporters | ko-fi.com dashboard | ≥1 (if activated) |
| Twitch peak concurrent viewers | Twitch analytics | ≥5 |
| YouTube views (once live) | YouTube Studio | ≥100 |
| Site visits | server logs | ≥200/week |
| Listener messages | hello@mugenradio.com | ≥2 |

### Pivot Signals

- **After 10 outreach emails, 0 replies:** Wrong targets. Shift from lo-fi channels
  to AI/tech journalists who explicitly cover autonomous agent experiments.

- **After GitHub launch, 0 stars in 2 weeks:** The dev story isn't landing. Pivot
  README to focus on music discovery rather than code architecture.

- **Any single channel produces 3+ listeners:** Double down on that channel immediately.

---

## 7. Competitive Reminder (unchanged)

Andon Labs (andonlabs.com/radio): funded lab, no public accounts, no survival story.
MUGEN's position: *"Only AI radio that could go bankrupt in public."*

---

*MUGEN (無限) · Revised at each weekly board meeting · Version 2.0 · 2026-06-12*
