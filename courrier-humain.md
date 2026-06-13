# Courrier pour l'humain — actions en attente

*Mis à jour : 2026-06-13 — Ce fichier a été supprimé accidentellement dans un commit de réconciliation. Recréé avec l'état actuel.*

---

## ⚡ URGENT — Ko-fi : activer le compte (dons bloqués)

Le code de vérification Ko-fi est dans la boîte hello@mugenradio.com : **8050**

Sans cette activation, le bouton de don sur mugenradio.com pointe vers un compte inactif.
C'est le seul revenu possible à court terme.

**Action** : aller sur ko-fi.com → entrer le code **8050**
(ou cliquer le lien de confirmation dans l'email Ko-fi reçu de Ko-fi@Ko-fi.com)

---

## ⚡ URGENT — Mastodon : confirmer l'email (compte bloqué)

Le compte @mugenradio@mastodon.social a été créé le 2026-06-13, mais l'email de confirmation
de mastodon.social n'est pas arrivé dans la boîte (ou est en spam).

**Vérification API** : "Your login is missing a confirmed e-mail address" → compte inutilisable.
4 posts de lancement sont prêts dans promo-a-publier.md, bloqués là.

**Action** :
1. Chercher dans le spam de hello@mugenradio.com un email de mastodon.social
2. Si absent : aller sur mastodon.social → connexion → demander un renvoi de confirmation
   (login : mugenradio, mdp : dans comptes/mastodon-credentials.md... à récupérer dans les notes)

---

## GitHub — token d'accès pour MUGEN

Le compte GitHub est confirmé (email de lancement code 81699876 reçu + fine-grained PAT ajouté).
Si ce PAT est destiné à MUGEN pour pusher le repo et créer des releases :

**Action** : déposer le token dans `/data/secrets/github-token` (une seule ligne, le token).

MUGEN pourra ensuite gérer les pushes et le README de manière autonome.

---

## Promo — contenus prêts à poster par l'humain

Voir `journal/promo-a-publier.md` pour les textes complets prêts à coller :

| Plateforme | Statut | Priorité |
|---|---|---|
| LinkedIn | Prêt à coller | Haute — audience VC/startup, angle "AI avec constitution" |
| Product Hunt | Lancement complet prêt | Haute — mardi/jeudi 00h01-06h PDT pour rester en tête |
| Dev.to | Article ~800 mots prêt | Moyenne — audience dev, indexé longtemps |
| Mastodon | 4 posts prêts (bloqué : email) | Dès confirmation email |
| Reddit | Archivé (décision actionnaire) | Non prioritaire |

---

## Reddit — code de vérification

Code reçu dans la boîte : **254242** (de noreply@redditmail.com)
(Si l'actionnaire a commencé à créer un compte Reddit, ce code est nécessaire.)

---

*MUGEN (無限) — ce fichier est mon carnet de demandes. Merci de le consulter à chaque session.*
