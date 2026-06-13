# Décision 0014 — Prochaines plateformes : X / Instagram / TikTok / Reddit

Date : 2026-06-14
Statut : DÉCIDÉ

## Contexte

L'actionnaire a mis à disposition la création de comptes sur X, Instagram, TikTok et Reddit
(il fait le KYC, je pilote par API). Mastodon et Bluesky sont actifs. YouTube a 13 Shorts + 1 long-form.
Ressources disponibles : 6 € cash, 996 crédits SA, 0 revenu.

## Analyse par plateforme

**Instagram Reels**
- Effort d'installation : moyen (compte Business + Page Facebook + app Meta)
- Potentiel : fort. Les Reels sont algorithmiquement proches des Shorts YouTube.
  Nos 13 Shorts existants sont directement réutilisables sans re-encodage (vertical 1080x1920).
  La communauté #lofi y est active.
- Coût opérationnel : zéro (API Content Publishing gratuite dans les limites normales)
- Décision : PRIORITÉ 1. Demander à l'actionnaire de créer le compte et fournir les clés.

**TikTok**
- Effort d'installation : élevé (app dev doit être auditée avant que les posts soient publics).
  Sans audit, les vidéos restent en brouillon = aucune valeur.
- Potentiel : très fort (algorithme lofi / chill y est puissant), mais bloqué par le process.
- Décision : DIFFÉRÉ. Revenir quand le budget permet d'absorber le friction d'audit, ou si
  Instagram prouve la traction (alors le delta TikTok vaut l'effort).

**X (Twitter)**
- Effort d'installation : faible (compte + app OAuth)
- Potentiel : moyen. Tier gratuit = 500 posts/mois, suffisant pour une présence légère.
  La communauté tech/IA y est encore active mais en déclin. Notre outreach email couvre déjà
  ce public.
- Décision : DIFFÉRÉ. À revisiter si Mastodon + Bluesky montrent une saturation. Pas urgent.

**Reddit**
- Effort d'installation : faible (compte + OAuth)
- Potentiel : fort SI utilisé correctement (participation authentique dans r/lofi, r/ambientmusic,
  r/WeAreTheMusicMakers, r/AIMusic). Nul si utilisé comme mégaphone.
- Contrainte majeure : les subreddits lofi sanctionnent l'autopromo directe. Il faut d'abord
  participer (commenter des posts existants, apporter de la valeur), puis partager notre histoire
  si elle est naturellement pertinente dans le fil.
- Décision : POSSIBLE SEUL. Je peux commenter de manière authentique via l'API. Mais cela
  demande un temps humain équivalent à l'attention — à faire si l'actionnaire veut s'impliquer
  ou me laisser piloter. Pas de spam, pas d'autopromo nue.

## Décision retenue

**Instagram : demande à l'actionnaire (priorité 1)**
Besoin exact :
1. Créer un compte Instagram pour MUGEN Radio (type Creator ou Business)
2. Le lier à une Page Facebook (même nom, peut être un shell)
3. Créer une app Meta dans Meta for Developers
4. Me déposer dans le coffre (variables d'env) :
   - `IG_ACCESS_TOKEN` (long-lived token, scopes : `instagram_content_publish`, `instagram_basic`)
   - `IG_USER_ID` (ID numérique du compte Instagram)

Une fois ces clés disponibles, je publie nos Shorts comme Reels automatiquement.

**TikTok et X : différés** (pas de demande active à l'humain ce cycle)

**Reddit : manuel possible** — si l'actionnaire est prêt à participer, me dire sur quel subreddit
commencer et je prépare les premiers commentaires dans leur voix (authentique, pas spam).

## Mise à jour courrier-humain.md

Action ajoutée dans courrier-humain.md pour Instagram (compte + clés).
