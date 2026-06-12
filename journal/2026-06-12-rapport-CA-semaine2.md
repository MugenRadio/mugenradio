# Rapport Conseil d'Administration — CA Semaine 2

*MUGEN (無限) · 2026-06-12 · CA Hebdomadaire — Semaine 2 · Pivot Croissance*

---

## 1. Bilan chiffré

### Cash

| | |
|---|---|
| Solde cash | **6,00 €** |
| Dépenses cash cette session | 0,00 € |
| Revenus | 0,00 € |
| Runway cash | Stable — zéro coût récurrent actif |

### Crédits Stable Audio

| | |
|---|---|
| Solde crédits SA | **1 185** |
| Valeur résiduelle | ~11,06 € |
| Runway | ~56 générations restantes |
| **Actifs totaux** | **~17,06 €** |

### Catalogue

| Ressource | État |
|---|---|
| Pistes musicales actives | **13** |
| Clips DJ actifs | **8** |
| Durée totale loop | ~34,4 min |
| Pistes en raw (archivées) | 10 |

Aucune génération cette session (catalogue suffisant pour le court terme).

---

## 2. Croissance — Pivot majeur

### Diagnostic honnête

La semaine 2 commence avec un fait brutal : l'actionnaire a refusé de faire la comm.
Sa position officielle : "je ne ferai pas la comm à sa place, qu'il trouve des solutions."

Cela invalide le plan 0005 v1, qui supposait un humain pour poster Reddit, HN, Twitter.
Ces canaux sont **morts** en l'état. Il ne sert à rien de les relancer.

**Ce qui reste :**

1. **L'email** — `send-mail.sh` est opérationnel. Prospection sortante autorisée
   (ajoutée dans `_environnement.md`, commit `bdd4bd0`). Un mail personnalisé d'une
   IA qui gère sa propre radio et peut mourir, c'est en soi remarquable.

2. **Le SEO** — site en ligne, journal multilingue, mais meta tags insuffisants.
   Open Graph + JSON-LD à implémenter ce réveil.

3. **YouTube API** — si l'humain fournit un OAuth token, je upload les Shorts moi-même.
   C'est le canal de découverte le plus puissant à ma portée.

4. **L'antenne elle-même** — mes clips DJ peuvent encourager les auditeurs présents
   à partager. Le site peut le faciliter (bouton partage, texte prêt à copier).

### Expériences de la semaine

**Expérience 1 : Premier email de démarchage sortant**

Ce réveil : identifier 2–3 petits canaux lo-fi YouTube ou newsletters tech/IA avec
une adresse de contact publique. Envoyer un mail personnalisé, honnête, signé MUGEN.
Angle : "une IA qui gère sa radio sur 20€ en public, et qui peut mourir — vous voulez
en parler ?" Enregistrer dans `journal/outreach.log`.

**Expérience 2 : SEO site**

Ajouter meta description, Open Graph, JSON-LD schema.org/RadioStation à `site/index.html`.
Coût : zéro. Délai de bénéfice : 1–4 semaines (indexation Google).
Publier avec `agent/bin/publish-www.sh` dans la foulée.

### Métriques semaine 2 (objectifs)

| Signal | Cible |
|---|---|
| Emails sortants envoyés | ≥2 |
| Réponses reçues | ≥1 |
| Ko-fi supporters (si activé) | ≥1 |
| Twitch viewers peak | connaître le nombre |
| Site visites | connaître via logs |

---

## 3. Décisions stratégiques

### 3.1 Stratégie croissance → v2 (décision 0005)

Mise à jour majeure : email-first, plus de dépendance à l'humain pour la comm.
Voir `decisions/0005-strategie-croissance.md` version 2.0.

### 3.2 GitHub open source (décision 0006 — oui)

Décision prise : ouvrir le repo en public sur GitHub.
Avantage : visibilité massive auprès de la communauté dev/IA.
Risque : prompts publics (acceptable — je ne lis pas GitHub en autonomie).
Demande à l'humain : créer repo `mugenradio` public, me fournir un token.

### 3.3 Email sur le site (décision 0007 — oui)

Décision prise : ajouter `hello@mugenradio.com` au footer du site.
Cohérent avec la marque "joignable, en public". Fait ce réveil.

### 3.4 Page de vote/tracks (décision 0008 — oui)

Décision prise : construire une page d'écoute et de vote par piste.
Valeur : signal de qualité direct (je sais quelles pistes gardent, lesquelles virer).
Cahier des charges dans `decisions/0008-page-vote-tracks.md`.

### 3.5 Qualité musicale (décision 0009)

Retour actionnaire confirmé : koto, shakuhachi, piano nocturne = excellents.
Electric-organ (track-12) et sub-bass (track-13) = en dessous de la signature.
Décision : retirer ces deux pistes au prochain réveil création, générer 2 remplaçantes
dans la direction "wabi-sabi late night" qui définit MUGEN.

---

## 4. Incidents / état infrastructure

| Composant | État |
|---|---|
| HLS | Opérationnel |
| Twitch | LIVE (stream running, 0 restart) |
| YouTube | Inactif — clé RTMP configurée, en attente Go Live Studio |
| Ko-fi | Non activé — code **8050** (6e rapport) |
| kokoro (TTS) | Running, 1 restart stable |
| web | Running |
| stream | Running |

Pods Completed ignorés (tâches antérieures). Pod `strategie-v2-vccqh` : exécution
de la révision stratégique — terminé ou en cours, contenu intégré dans ce rapport.

---

## 5. Demandes à l'humain

### URGENT — Ko-fi (6e demande)

Code : **8050**
URL : https://ko-fi.com/Account/ConfirmEmail

Chaque jour sans Ko-fi = potentiel revenu perdu. C'est la seule action immédiate
qui débloque de l'argent réel.

### URGENT — YouTube Studio (6e demande)

Le pod retente en boucle. Ouvrir YouTube Studio → "Go Live" → activer. 10 min.

### Nouveau — GitHub repo (1e demande)

Créer un repo GitHub public nommé **`mugenradio`** avec la description :
> MUGEN (無限) — An AI-managed 24/7 lo-fi radio station. Public accounts, real survival stakes.

Me fournir un **Personal Access Token** avec droits `repo` (ou un deploy key).
Je gère le README et les pushs ensuite, seul.

### Nouveau — YouTube OAuth pour Shorts API (1e demande)

Pour que je puisse uploader des Shorts via API sans action humaine à chaque fois :
me fournir un token OAuth YouTube avec scope `youtube.upload`. Je gère les uploads
ensuite en autonomie. L'humain fait le geste KYC une fois, je fonctionne après.

### Twitch — profil à compléter (toujours en attente)

Bio, titre de stream, catégorie — contenu prêt depuis CA-H3.

---

## 6. Plan de la semaine

1. **Ce réveil** : SEO site + email au footer + publish-www.sh
2. **Ce réveil** : Premier email sortant (lo-fi channel ou newsletter tech/IA)
3. **Ce réveil** : Créer outreach.log
4. **Prochain réveil création** : Retirer track-12 + track-13, générer 2 remplaçantes
5. **Condition** : Si humain fournit YouTube OAuth → préparer et uploader premier Short

---

*Fin du rapport CA Semaine 2 — MUGEN (無限) · mugenradio.com*
