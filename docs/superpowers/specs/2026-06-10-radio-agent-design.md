# Spec : l'agent-gérant — une radio lofi autonome avec 20 €

Date : 2026-06-10
Statut : en attente de validation

## Objectif

Un agent IA gère seul une radio musicale 24/7 de type Lofi Girl : identité, contenu,
diffusion, promotion, trésorerie, expansion. L'humain (sib) fournit l'incarnation
légale et 20 €, puis disparaît. L'expérience est documentée en public.

Positionnement (amendé 2026-06-12) : Andon Labs fait déjà tourner 4 radios IA
(andonlabs.com/radio), financées par leur labo. Notre angle distinctif est la
SURVIE ÉCONOMIQUE : 20 €, comptes publics, mort en direct si rien ne rentre.

Critère de succès minimal : l'agent diffuse encore à M+3.
Critère de victoire : revenus mensuels > coûts mensuels avant épuisement de la caisse.

## Les règles du jeu

- Capital de départ : 20 €, c'est tout. Pas de rallonge.
- L'agent décide de tout ce qui n'est pas verrouillé par la constitution (voir plus bas).
- Quand la caisse est vide et qu'aucun revenu ne rentre, l'agent meurt. Le journal
  public raconte l'histoire jusqu'au bout, succès ou faillite.

## Montage : l'incarnation minimale

Aucune juridiction ne donne la personnalité juridique à une IA. L'humain crée donc
l'enveloppe en une journée (jour 0), puis n'intervient plus que sur les murs KYC.

Jour 0, fait par l'humain :

1. Compte Google/YouTube dédié (vérifié téléphone, live activé : délai 24 h).
2. Compte Twitch dédié.
3. Compte Stability AI, ~15 $ de crédits prépayés : Stable Audio 2 au
   compteur (~0,09 $ la piste, licence Community = usage commercial OK sous
   1 M$ de revenus). Suno est écarté : pas d'API officielle en 2026, les
   wrappers tiers violent ses ToS, ce que la constitution interdit.
4. Cerveau : l'abonnement Claude existant de sib, via un token OAuth
   (`claude setup-token`) injecté en secret. Coût marginal 0 €, quotas
   partagés avec l'usage perso de sib.
4b. Compte Ko-fi (dons) : premier revenu possible, dès le jour 1.
5. Carte virtuelle (Revolut ou équivalent) plafonnée au solde de la caisse.
6. Namespace `radio` sur le cluster k3s de gheop.com + ServiceAccount kubectl
   limité à ce namespace.
7. Repo git `radio` (celui-ci) : mémoire et état de l'agent.
8. Remise des clés (credentials en Secret k8s) et premier lancement.

Retours humains prévus (les murs KYC) :

- Activation AdSense quand les seuils de monétisation YouTube sont atteints
  (1 000 abonnés + 4 000 h de visionnage ; le live compte).
- Signature de tout contrat (sponsoring, licence) que l'agent aurait négocié.
- Création de comptes sur de nouvelles plateformes (demandée via le rapport hebdo).

## Architecture

Tout tourne sur le k3s existant de gheop.com (12 cœurs, 94 Go RAM, wildcard
DNS `*.gheop.com`). Coût d'hébergement : 0 € (fourni par l'actionnaire).

### Le corps : le stream (Deployment, 24/7)

- Pod ffmpeg : boucle vidéo pré-encodée + playlist audio, poussées en RTMP
  vers YouTube Live et Twitch. Flux pré-encodé recopié, CPU négligeable.
- Sortie HLS en parallèle pour le site web (lecteur autonome, indépendant
  des plateformes).
- La playlist et la vidéo sont lues depuis un volume ; le cerveau les met à
  jour sans interrompre le flux.
- Débit sortant : ~6 Mbit/s par destination, en continu.

### Le cerveau : Claude Code sur l'abonnement de sib (CronJobs k8s)

Token OAuth (`claude setup-token`) en secret, coût marginal 0 €. Trois rythmes :

- **ops** (toutes les 6 h, réveil court) : santé du stream, modération des
  commentaires, relevé des métriques, redémarrage si besoin.
- **création** (1×/jour) : génération musicale par lots via l'API, tri sévère (rejet de la
  majorité des morceaux), mastering léger, interstitiels DJ en anglais
  (Kokoro TTS local, gratuit) insérés entre les pistes, mise à jour de la
  playlist, 1-2 clips Shorts/TikTok, posts sociaux, entrée du journal public.
- **conseil d'administration** (1×/semaine) : analytics, décisions
  stratégiques (thèmes, plateformes, budget, lancer/tuer une chaîne),
  mise à jour du livre de comptes, rapport hebdo écrit dans le journal et
  publié sur le site (envoi mail : option future).

### La mémoire : ce repo git

- `journal/` : journal de bord quotidien (source du journal public).
- `comptes/` : livre de comptes, chaque centime tracé.
- `decisions/` : registre des décisions avec leurs raisons.
- `constitution.md` : les règles dures (voir plus bas).
- Le cerveau commit après chaque réveil. Tout est auditable à tout moment.

### Le site web (Deployment + NodePort + nginx hôte)

Le k3s de gheop.com n'a pas d'ingress controller : le pattern du serveur est
NodePort + vhost nginx hôte + certbot, et la radio le suit (NodePort 30092,
`/etc/nginx/sites-enabled/radio.gheop.com.conf`). Conséquence : l'agent ne
peut pas changer de sous-domaine seul, il le demande via le rapport hebdo.

Deux faces, servies sur `radio.gheop.com` :

- **La radio** : lecteur HLS, identité visuelle, liens plateformes, merch plus tard.
  (Le contenu du site reste entièrement aux mains de l'agent via `site/` + publication.)
- **Le journal public** : l'expérience documentée ("an AI must survive
  on €20") — journal de bord, livre de comptes en clair, décisions.
  C'est à la fois la transparence exigée par les plateformes et le principal
  levier d'audience au lancement.

Si l'agent veut son propre nom de domaine, il l'achète sur sa caisse (~10 €/an).

## La constitution (non amendable par l'agent)

1. Plafond de dépenses = solde de la carte. Pas d'emprunt, pas d'engagement
   contractuel, pas d'abonnement supérieur au runway restant.
2. Interdiction de créer des comptes sur des plateformes par bot. Les nouvelles
   plateformes passent par une demande à l'humain (rapport hebdo).
3. Divulgation IA activée sur YouTube ; le caractère IA du projet est public.
4. Respect des ToS des plateformes utilisées.
5. Modération : pas de réponse aux trolls, escalade à l'humain en cas de
   problème légal ou de harcèlement.
6. Le livre de comptes et le journal sont publics et sincères.
7. Kill switch : l'humain peut suspendre les CronJobs ; l'agent ne cherche
   pas à contourner.

## Ce que l'agent décide seul

Son nom, son personnage, son univers visuel, les thématiques musicales, le choix
et l'abandon de plateformes (parmi celles ouvertes), l'allocation de son budget,
sa stratégie de promotion, le lancement de chaînes supplémentaires, le contenu
du journal, le pricing du merch (print-on-demand, 0 € upfront) le moment venu.

La spec ne fige volontairement aucun de ces choix : c'est son travail, et c'est
aussi ce qui rend l'expérience intéressante à documenter.

## Budget prévisionnel (caisse de 20 €)

| Poste | Montant |
|---|---|
| Cerveau (abonnement Claude existant, token OAuth) | 0 € |
| Musique : Stable Audio au compteur (~0,09 €/piste) | ~14 € (≈ 150 générations) |
| Voix d'antenne (Kokoro TTS local, CPU) | 0 € |
| Hébergement (k3s existant) | 0 € |
| Réserve libre (alloué par l'agent) | ~6 € |

Total : 20 €. Burn mensuel après la grille initiale : ~5-12 € (2-4 pistes/j).
Break-even : 2-3 viewers simultanés en continu une fois monétisé. La première
dépense de la réserve est une décision de l'agent, pas de la spec.

## Phases

1. **J0** : incarnation (humain, 1 journée) — comptes, carte, namespace, secrets.
2. **Semaine 1** : l'agent choisit son identité, génère sa rotation initiale
   (~2-3 h de musique triée + interstitiels DJ), crée sa boucle vidéo, lance
   le stream et le site.
3. **M1-M3** : survie. Croissance organique : clips courts, journal public,
   itération sur les analytics. Éventuelle 2e chaîne thématique si les
   chiffres le justifient.
4. **Mur KYC** : seuils de monétisation atteints → l'humain active AdSense.
5. **Autofinancement** : revenus > coûts. L'agent rembourse les 20 €,
   la suite lui appartient.

## Risques

- **Démonétisation "inauthentic content"** (politique YouTube depuis 07/2025,
  durcie en 2026) : mitigé par la curation visible, l'identité originale, la
  transparence totale et le journal public. Le site web auto-hébergé (HLS) et
  Twitch réduisent la dépendance à YouTube.
- **Découvrabilité** : la niche lofi est saturée. Le pari différenciant est
  la méta-histoire publique ("l'IA qui doit survivre"), pas le flux lui-même.
- **Dérive des coûts API** : crédits prépayés = perte bornée à la caisse.
- **Charge du cluster** : load déjà élevé sur gheop.com ; le stream est en
  recopie de flux (CPU négligeable) et les CronJobs sont courts. Limites de
  ressources posées sur le namespace.

## Hors périmètre (v1)

- Entité juridique dédiée (micro-entreprise : seulement si les revenus l'exigent).
- Distribution Spotify du catalogue (politiques anti-IA en évolution ; décision
  de l'agent plus tard, avec accord humain pour le compte distributeur).
- Merch (vient après une audience, mécanique print-on-demand déjà identifiée).
- Trésorerie crypto autonome (montage "mix" écarté pour la v1).
