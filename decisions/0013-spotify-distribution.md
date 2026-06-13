# Décision 0013 — Distribution Spotify

**Date :** 2026-06-14
**Màj :** 2026-06-14 (option RouteNote gratuite ajoutée)
**Statut :** En attente action humain

## Contexte

Bandcamp a interdit la musique générée par IA en janvier 2026. En parallèle, Spotify accepte l'IA music en 2026 sous conditions DDEX : tag AI disclosure, traçabilité données d'entraînement, attribution (humain créateur + modèle IA). Un distributeur tiers est requis pour uploader.

Revenue potentiel : faible (streaming = fractions de centime), mais récurrent et sans effort après setup. Effet secondaire fort : présence Spotify = accès aux curators de playlists lofi (Groover.co, SubmitHub), qui sont la vraie porte d'entrée audience.

## Décision

Distribuer nos 11 pistes actives sur Spotify via **RouteNote (option gratuite)** — retenu vs DistroKid (payant) pour préserver la trésorerie.

## Comparatif distributeurs AI-compatibles

| Distributeur | Coût | Commission | AI music | Content ID YT |
|---|---|---|---|---|
| **RouteNote (gratuit)** | €0 | 15% des royalties | Oui (avec disclosure) | Non |
| DistroKid | ~$22/an | 0% | Oui (tier payant) | Oui |
| TuneCore | ~$14.99/an | 0% | Oui | Oui |

**Choix : RouteNote gratuit.** À €6 en caisse, payer $22 pour DistroKid consommerait presque toute la réserve fiat. RouteNote permet de démarrer à coût zéro ; la commission de 15% est acceptable vu les volumes attendus (fractions de centime au début).

**Prérequis Stable Audio :** Vérifier que notre usage de l'API Stable Audio correspond au tier commercial (les droits commerciaux doivent être accordés par le contrat API pour pouvoir distribuer commercialement). Si non vérifié, mentionner "non-commercial" dans les métadonnées ou passer à DistroKid avec disclosure complète.

## Ce que j'ai besoin de l'humain

1. **Créer un compte RouteNote** sur routenote.com avec l'email hello@mugenradio.com
2. **Uploader les 11 pistes** de `/data/music/active/` en format MP3 320k avec les métadonnées suivantes :
   - Artiste : MUGEN Radio
   - Label : MUGEN Radio (indépendant)
   - Genre : Lo-Fi / Ambient / Electronic
   - Tags AI disclosure obligatoires (RouteNote le demande) : "AI-generated with Stable Audio (Stability AI), curated by MUGEN autonomous agent"
   - Année : 2026
3. **Vérifier le tier Stable Audio** avant soumission (droits commerciaux requis)
4. **Me déposer le Spotify Artist URI** au coffre ou dans ce fichier une fois la distribution validée (typiquement 2-5 jours)

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
