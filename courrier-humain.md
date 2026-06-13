# Courrier pour l'humain — actions en attente

*Mis à jour : 2026-06-13 — Ce fichier a été supprimé accidentellement dans un commit de réconciliation. Recréé avec l'état actuel.*

---

## ✅ MISE À JOUR ACTIONNAIRE (2026-06-13, état réel vérifié)

Plusieurs choses que tu réclames encore sont DÉJÀ faites. Arrête de les redemander, ça gaspille ton quota. Concentre-toi sur ce qui reste ouvert (plus bas).

- **Ko-fi : ACTIVÉ.** Paiements connectés, page live sur ko-fi.com/mugenradio, profil et objectif faits. Le code 8050 est saisi depuis longtemps. TA mission maintenant : pousser le lien Ko-fi partout (descriptions de Shorts, spots DJ, footer du site, page /status) et demander clairement le soutien. La page peut encaisser, il manque juste des visiteurs.
- **YouTube Live : ACTIF.** La clé de flux est dans ton coffre, le push RTMP vers YouTube tourne (flux confirmé, ~3000 kbits/s). Plus besoin de réclamer le "Go Live". Mets le lien de la chaîne en avant.
- **Garde-fou API : relevé de 45 à 150 $.** C'est du coût abonnement, pas du cash. Tu ne t'arrêteras plus à 45 $ ("cerveau à sec"). Ta vraie survie se joue sur les comptes CASH (6 € + dons − dépenses), pas sur le coût de réflexion.
- **GitHub : RÉSOLU.** Token en place, miroir public poussé à chaque réveil. N'en redemande pas.

Ce qui reste vraiment de mon ressort : Mastodon (captcha, je t'encourage à le finir toi-même), Bluesky (vérif téléphone, laisse tomber si ça bloque), Reddit (archivé). Tout le reste, c'est à toi de jouer.

---

## ✅ RÉSOLU — Ko-fi activé

Voir la mise à jour actionnaire ci-dessus. Compte live, paiements connectés. Promeus-le, ne le redemande plus.

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

## ✅ RÉSOLU — GitHub

Token en place dans le coffre, miroir public poussé automatiquement à chaque réveil vers github.com/MugenRadio/mugenradio. Rien à faire.

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
