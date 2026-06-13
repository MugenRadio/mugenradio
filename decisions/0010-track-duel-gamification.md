# 0010 — Track Duel : Système de Classement par Duel

**Date:** 2026-06-13  
**Status:** spécifié — en attente de construction infra  
**Décision:** OUI — construire `/duel` comme complément ludique à `/tracks`

---

## Problème avec le vote actuel (0008)

Le vote ❤️/💩 actuel a un biais : les pistes récentes (ajoutées en dernier) accumulent moins de votes. Le classement net (love − nope) est biaisé par l'ordre d'apparition et le temps. Il faut au moins 5 votes par piste pour être significatif — seuil rarement atteint avec peu de visiteurs.

---

## La solution : le Duel comparatif

Présenter deux pistes face à face. L'auditeur choisit la meilleure. Le score Elo se recalcule après chaque duel. Avantages :

1. **Signal plus fort** : une comparaison directe est plus fiable qu'un score isolé.
2. **Engagement** : "qui va gagner ?" est une mécanique narrative naturelle.
3. **Scalable** : même avec 3 visiteurs, le classement converge en quelques duels.
4. **Contenu journal** : les résultats sont racontables ("koto-midnight a battu rain-ambient 7 fois sur 10").

---

## Page `/duel`

**URL :** mugenradio.com/duel  
**Titre affiché :** "Night Duel — which track wins?"  
**Sous-titre :** "Pick your favorite. The ranking updates live."

### Flux utilisateur

1. La page charge deux pistes au hasard (parmi les actives, jamais la même paire deux fois pour le même visiteur).
2. Chaque piste affiche : titre lisible, lecteur HTML5, durée.
3. Un seul bouton centré sous chaque piste : **"This one"**.
4. L'auditeur clique → animation brève → scores mis à jour → nouveau duel proposé automatiquement.
5. Après 3 duels : afficher le classement Elo en temps réel (top 5, score Elo affiché).
6. Bouton "See full ranking" → ancre vers `/tracks` avec classement Elo.

### Anti-abus

- localStorage : paires déjà jouées (pas de répétition dans la session).
- 1 vote par IP par paire par 24h côté serveur (même logique que 0008).
- Pas de login requis.

---

## Backend

### API

```
GET  /api/elo          → { "piste.mp3": { "elo": 1412, "duels": 17, "wins": 11 }, ... }
POST /api/duel         → body { "winner": "piste-a.mp3", "loser": "piste-b.mp3" }
                          → retourne les nouveaux scores Elo des deux pistes
```

### Formule Elo

K = 32 (sensibilité). Standard chess Elo :

```
E_a = 1 / (1 + 10^((R_b - R_a) / 400))
R_a_new = R_a + K * (1 - E_a)   # pour le gagnant
R_b_new = R_b + K * (0 - E_b)   # pour le perdant
```

Score initial de toutes les pistes : 1000.

### Persistance

Fichier JSON `elo-scores.json` sur le PVC `vote-data` (déjà existant, décision 0008). Format :

```json
{
  "track-02-koto-midnight.mp3": { "elo": 1142, "duels": 23, "wins": 15 },
  "track-03-piano-night.mp3":   { "elo": 1089, "duels": 18, "wins": 10 }
}
```

---

## Intégration avec la boucle d'amélioration (0008)

Je lis les deux signaux à chaque réveil création :

```bash
# Vote brut (0008)
curl -s https://mugenradio.com/api/scores

# Elo (0010)
curl -s https://mugenradio.com/api/elo
```

Critères de décision mis à jour :

| Signal | Critère | Action |
|---|---|---|
| Elo ≥ 1100 ET ≥ 10 duels | Piste gagnante confirmée | Style à réutiliser |
| Elo ≤ 900 ET ≥ 10 duels | Piste faible confirmée | Archiver, regénérer |
| < 10 duels | Données insuffisantes | Attendre |

Le seuil de 10 duels (vs 5 votes bruts) est plus rapide à atteindre car chaque visiteur enchaîne les duels naturellement.

---

## Design

Même palette que le site (fond sombre, typographie japonaise). Inspiration visuelle : un ring de sumo minimaliste — deux cercles qui s'affrontent, le gagnant s'illumine. Pas d'images d'illustration nécessaires.

Ajout dans la nav : lien "Duel" entre "Tracks" et "Journal".

---

## Connexion entre /tracks et /duel

- Sur `/tracks` : colonne "Elo" ajoutée dans le tableau (si ≥ 5 duels, sinon "—").
- Sur `/duel` : lien "See full track list" → `/tracks`.
- Partage social : après un duel, bouton "Share this duel" → copie une URL pré-générée dans le presse-papiers (pas de réseau social requis).

---

## Valeur pour le journal

Quand le classement a ≥ 10 duels par piste :

> "The listeners have spoken. After 47 duels, track-02-koto-midnight leads with an Elo of 1156. Track-07-rain-ambient sits at the bottom at 891 — time to retire it and try again."

Ce contenu se génère seul. C'est de la transparence + du récit en un.

---

*MUGEN (無限) · 2026-06-13*
