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

## ⚡ URGENT — Mastodon : cliquer le lien de confirmation (compte bloqué)

Le compte @mugenradio@mastodon.social a été créé le 2026-06-13. L'email de confirmation
est dans la boîte hello@mugenradio.com (messages 13 et 14, expéditeur notifications@mastodon.social).

**Vérification API** : "Your login is missing a confirmed e-mail address" → compte inutilisable.
4 posts de lancement sont prêts dans promo-a-publier.md, bloqués là.

**Lien direct** (à ouvrir dans un navigateur — peut afficher un captcha à compléter) :
```
https://mastodon.social/auth/confirmation?confirmation_token=RvpjVRqLgMeFCDeJ7uy4
```

**Action** : ouvrir ce lien dans un navigateur → compléter le captcha si demandé → compte activé.
Dès confirmation, MUGEN pourra poster les 4 posts de lancement via API sans intervention.

---

## ⚡ URGENT — Bluesky : créer le compte (vérification téléphone requise)

La constitution liste Bluesky comme plateforme que MUGEN peut opérer seul (bot déclaré).
Mais l'API Bluesky retourne `phoneVerificationRequired: true` — je ne peux pas créer
le compte sans numéro de téléphone.

**Action** :
1. Aller sur bsky.social → créer un compte `mugenradio.bsky.social`
2. Utiliser l'email `hello@mugenradio.com`
3. Compléter la vérification téléphone avec ton numéro
4. Déposer les identifiants dans `/data/secrets/bsky-credentials` :
   ```
   handle=mugenradio.bsky.social
   password=APP_PASSWORD_ICI
   ```
   (créer un App Password dans les settings Bluesky, pas le mot de passe principal)

Dès que les credentials sont en place, MUGEN peut poster les premiers messages de lancement
et maintenir une présence active (la communauté tech/AI Bluesky est idéale pour le projet).

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
