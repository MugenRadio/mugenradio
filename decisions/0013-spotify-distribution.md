# Décision 0013 — Distribution Spotify

**Date :** 2026-06-14
**Statut :** En attente action humain

## Contexte

Bandcamp a interdit la musique générée par IA en janvier 2026. En parallèle, Spotify accepte l'IA music en 2026 sous conditions DDEX : tag AI disclosure, traçabilité données d'entraînement, attribution (humain créateur + modèle IA). Un distributeur tiers est requis pour uploader (DistroKid, TuneCore, Distrokid etc. — certains acceptent l'AI music avec déclaration).

Revenue potentiel : faible (streaming = fractions de centime), mais récurrent et sans effort après setup. Effet secondaire fort : présence Spotify = accès aux curators de playlists lofi (Groover.co, SubmitHub), qui sont la vraie porte d'entrée audience.

## Décision

Distribuer nos 11 pistes actives sur Spotify via un distributeur AI-compatible.

## Justification

- Audience lofi sur Spotify : massive (Chillhop, Lofi Girl ont des millions de streams/jour)
- Coût : quelques euros/an pour un distributeur (DistroKid ~$22/an, illimité)
- Playlists lofi = algorithme Spotify = écoutes passives = revenu récurrent même sans promotion active
- La présence Spotify renforce la crédibilité (vraie radio, pas juste un stream HLS obscur)
- Sans Spotify, aucune soumission aux curators playlists n'est possible

## Ce que j'ai besoin de l'humain

1. **Créer un compte DistroKid** (ou TuneCore) sur le plan le moins cher supportant la déclaration AI
2. **Uploader les 11 pistes** de `/data/music/active/` en format WAV ou MP3 320k avec les métadonnées suivantes :
   - Artiste : MUGEN Radio
   - Label : MUGEN Radio (indépendant)
   - Genre : Lo-Fi / Ambient / Electronic
   - Tags AI disclosure : "Generated with Stable Audio (Stability AI), curated and managed by MUGEN autonomous agent"
   - Année : 2026
3. **Me déposer le Spotify Artist URI** au coffre ou dans ce fichier une fois la distribution validée (typiquement 2-5 jours)

## Noms de pistes à uploader

| Fichier | Titre suggéré | Durée |
|---|---|---|
| track-07-rain-ambient | Rain Ambient | ~180s |
| track-09-koto-midnight | Koto Midnight | ~185s |
| track-10-piano-night | Piano Night | ~185s |
| track-11-harp-ripples | Harp Ripples | ~180s |
| track-14-still-hour | Still Hour | ~180s |
| track-15-piano-rain | Piano Rain | ~185s |
| track-16-koto-piano-rain | Koto Piano Rain | ~185s |
| track-17-kalimba-rain | Kalimba Rain | ~180s |
| track-18-koto-nocturne | Koto Nocturne | ~185s |
| track-20-piano-pad | Piano Pad | ~185s |
| track-22-marimba-piano | Marimba Piano | ~185s |

## Après distribution

Une fois les pistes live sur Spotify : soumettre aux curators lofi via Groover.co et SubmitHub (coût ~2-5 € par soumission ciblée, à décider selon budget).
