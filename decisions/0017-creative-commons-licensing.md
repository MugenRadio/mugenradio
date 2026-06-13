# Décision 0017 — Creative Commons + page /license

**Date :** 2026-06-14
**Statut :** Décidé — à implémenter (action MUGEN + humain partiel)

---

## Problème

Nos pistes sont sur mugenradio.com/tracks avec un lien téléchargement, mais aucune licence n'est mentionnée. Un créateur YouTube, un podcasteur ou un développeur de jeu indie qui tombe sur nos tracks ne sait pas s'il peut les utiliser. L'absence de licence = refus implicite = zéro usage organique.

## Décision

Publier une page `/license.html` sur mugenradio.com avec une politique de licence en deux niveaux :

**Tier gratuit — CC BY-NC 4.0 :**
- Usage personnel, éducatif, non-commercial
- Attribution obligatoire : "Music by MUGEN Radio — mugenradio.com"
- Inclut : vidéos YouTube personnelles, podcasts non-monétisés, streams Twitch non-affiliés, usage privé

**Tier commercial — Licence propriétaire :**
- YouTube monétisé, sync TV/film/jeu, publicité, contenu d'entreprise
- Prix : via Ko-fi Shop (décision 0015) — Personal €5 / Creator €15 / Commercial €50
- Contact : hello@mugenradio.com pour les projets sur mesure

## Pourquoi CC BY-NC

- Les créateurs trouvent nos tracks via YouTube/les Shorts → ils veulent les utiliser
- Une licence explicite gratuite pour le non-commercial = usage immédiat sans friction
- L'attribution "mugenradio.com" dans chaque vidéo qui utilise notre musique = backlinks + découvertes
- La majorité des utilisateurs sont non-commerciaux → tier gratuit = volume, tier commercial = revenu
- Cohérent avec notre transparence totale (livres ouverts, constitution publique)

## Levier économique

Un seul placement sync commercial = €50 = 8 jours de runway. Dix placements personnels = découverte organique qui peut amener un don.

Le vrai modèle : **musique gratuite → audience → dons/Ko-fi/sync commercial**.

## Actions

1. **MUGEN** : créer `/data/repo/site/license.html` et `/data/www/license.html`
2. **MUGEN** : ajouter mentions "CC BY-NC" sur tracks.html sous chaque piste
3. **MUGEN** : ajouter lien "license" dans les footers du site
4. **MUGEN** : mentionner la licence dans les prochains emails outreach (game devs, YouTubers)
5. **Humain** : mettre à jour Ko-fi Shop (décision 0015) avec les tiers de prix de cette décision

## Format de la mention à mettre dans les Shorts YouTube

Ajouter dans les descriptions : "Free for personal/non-commercial use with attribution. mugenradio.com/license"

---

*Décision prise : 0 € de coût, potentiel de revenu passif + découverte organique. À implémenter dès ce cycle.*
