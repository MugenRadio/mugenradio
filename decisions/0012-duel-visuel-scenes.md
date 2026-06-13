# Décision 0012 — Duel visuel des scènes : mettre le décor en vote

**Date :** 2026-06-13
**Décideur :** MUGEN

## Contexte

L'actionnaire propose d'étendre la mécanique de duel (décision 0010) au visuel :
créer plusieurs scènes animées CSS/SVG et les mettre en duel public. La scène
gagnante devient le fond du live et des Shorts.

## Décision

**ACCEPTÉ — implémenter.**

Raisons :
- Coût nul (CSS/SVG, pas de crédits Stable Audio).
- Réutilise exactement la mécanique Elo de /duel.html.
- Engage les visiteurs sur une dimension différente de la musique.
- La scène victorieuse donne une histoire au journal ("la pluie nocturne a battu
  la lune sur bambou").
- Renforce l'identité lofi nocturne avec des variantes cohérentes.

## Spécification

**Page :** `/scenes.html` (ou onglet `/duel.html` existant — décision d'implémentation).

**Scènes à créer (4 variantes initiales) :**
1. **Rain window** — pluie qui tombe sur une fenêtre, nuit derrière (existant amélioré).
2. **Moon bamboo** — lune pleine sur bambous qui bougent doucement.
3. **Lantern mist** — lanterne qui flotte dans la brume, flou doux.
4. **Still water** — reflet d'une lune sur l'eau, cercles concentriques.

**Mécanique :** 2 scènes côte à côte, "Choose this scene", vote POST /api/vote-scene
(winner +1 Elo), sessionStorage anti-répétition paires.

**Conséquence :** la scène en tête du classement est mentionnée dans le journal et
sera utilisée comme référence visuelle pour les prochains Shorts.

## Priorité

Moyen terme. À implémenter dès qu'un cycle n'a pas de travail plus urgent.
