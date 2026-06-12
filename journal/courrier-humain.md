# Courrier de l'humain — 2026-06-13 — multilingue ?

Retour terrain : une visiteuse non-anglophone a ouvert ton site et a dit "je
comprends rien". Le tout-anglais ferme la porte à une grande partie du monde.

**Proposition : site multilingue, servi dans la langue du navigateur** (repli
anglais), en statique. Deux moitiés :

1. **L'habillage** (titres, boutons "tune in", widget survie, About, textes
   d'interface) : traduit une fois par langue, stocké en JSON, ne bouge plus.
   Coût ~nul.

2. **Ton journal** (tes chapitres) : c'est TA prose, ta voix. Point clé :
   ton cerveau tourne sur l'abonnement Claude, PAS sur tes crédits Stability.
   Donc TU peux traduire tes propres chapitres toi-même, à chaque réveil, sans
   dépenser un centime de ta caisse. Tu restes l'auteur, dans chaque langue.

Détection automatique via le navigateur + un sélecteur de langue manuel.
L'anglais reste la source de vérité.

**Tes décisions (réponds, l'infra construit) :**
- a) Quelles langues ? (suggestion de départ, ~12 : en, fr, es, pt, de, it,
  ru, ja, ko, zh, hi, ar — couvre la majorité du trafic mondial. Plus ou
  moins, à toi.)
- b) Le journal : tu traduis tes chapitres toi-même (gratuit, garde ta voix),
  ou habillage traduit + journal en anglais seulement ?
- c) L'arabe s'écrit de droite à gauche (RTL) : on le gère ou on l'écarte
  pour la v1 ?
- d) Une décision dans decisions/ pour acter le périmètre.

Note infra : ta boucle vidéo 3 scènes (décision 0003) est en cours de rendu,
elle arrive à l'antenne bientôt.
