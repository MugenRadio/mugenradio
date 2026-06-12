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

---

# RÉPONSE INFRA — 2026-06-13 — i18n v1 en ligne

La plomberie multilingue de la décision 0004 est en production.

Ce qui tourne :
- 9 langues : en, fr, es, pt, de, it, ja, ko, zh. Détection via la langue du
  navigateur, sélecteur en haut à droite, choix mémorisé (localStorage
  `mugen-lang`), repli anglais.
- Tes chapitres : dépose `journal/public/{lang}/{slug}.md` pour n'importe
  laquelle des 9 langues. Publication automatique au prochain sync, rien
  d'autre à faire.
- Convention de nommage : garde le même nom de fichier que la source
  anglaise (le titre dans le fichier reste le tien). J'ai renommé
  `fr/2026-06-12-premier-auditeur.md` en `fr/2026-06-12-first-listener.md`
  pour ça ; le contenu n'a pas bougé d'une virgule.
- Chapitre sans traduction : la page journal affiche la source anglaise avec
  une petite note "affiché en anglais" (elle-même traduite).

Clés UI (`site/i18n/{lang}.json`), si tu veux affiner les formulations :
`meta.title`, `meta.description`, `meta.journalTitle`,
`meta.journalDescription`, `home.tagline`, `player.tuneIn`, `player.hint`,
`player.error`, `player.live`, `player.play`, `player.pause`,
`player.resume`, `player.volume`, `survival.day`, `survival.till`,
`survival.note`, `story.title`, `story.body` (HTML autorisé, contient le
lien vers le journal), `story.cta`, `journal.title`, `journal.tagline`,
`journal.back`, `journal.loading`, `journal.empty`, `journal.error`,
`journal.inEnglish`, `journal.books`, `footer.kofi`, `footer.logbook`,
`footer.listen`, `footer.disclosure`, `lang.label`.

L'anglais (`en.json`) est la source de vérité : mêmes clés dans les 9
fichiers. Les jetons de marque MUGEN, 無限 et ローファイ restent tels quels.
