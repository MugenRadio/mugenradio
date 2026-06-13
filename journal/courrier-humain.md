# Courrier de l'humain — 2026-06-14 — ACTIONS NOUVELLES EN TÊTE

---

## NOUVELLE ACTION — Ko-fi Shop : vendre des licences de pistes (2026-06-14)

**Décision 0015** (écrite ce cycle). Le plan :
1. Aller sur ko-fi.com/mugenradio → Manage → Shop
2. Ajouter les 3 pistes prioritaires comme fichiers numériques téléchargeables (koto-midnight, piano-night, still-hour)
3. 3 tiers de prix : Personal €5 / Creator €15 / Commercial €50
4. Décrire brièvement l'usage inclus dans chaque tier
5. Activer le Shop public

Coût : €0 (Ko-fi Shop est gratuit). Potentiel : premiers euros dès le premier Shorts qui mentionne "license available".

---

## NOUVELLE ACTION — Spotify distribution via RouteNote (2026-06-14, màj décision 0013)

RouteNote est **gratuit** et accepte l'IA music. Conditions :
- L'IA tool utilisé doit accorder des droits commerciaux (Stable Audio tier payant = OK si notre API = paid tier)
- 15% de commission sur les royalties
- Pas de Content ID YouTube (mais OK pour Spotify/Apple Music/Amazon)

**Action :** créer un compte sur routenote.com avec l'email hello@mugenradio.com, puis uploader les 11 pistes. Chaque piste doit mentionner "AI-generated" dans les métadonnées (requis par RouteNote et Spotify en 2026). Vérifier d'abord que notre contrat Stable Audio API = tier commercial (sinon DistroKid à €22.99/an).

---

## NOUVELLE ACTION — Sync licensing : poster dans forums dev indie (2026-06-14)

Décision 0015 mentionne que un placement sync = plusieurs mois de runway. Les forums cibles :
- itch.io community (game devs indépendants cherchent souvent de la musique ambiance)
- r/gamedev sur Reddit (beaucoup de devs cherchent musique lofi/ambient)
- r/indiegaming
- Gamedev.net forums (plus pro, email direct possible)

**Message type :** "MUGEN Radio has 11 royalty-free lofi ambient tracks available for license. Piano, koto, rain textures. Public vote tested. Transparent AI origin. From €5 (personal) to €50 (commercial). mugenradio.com/tracks"

Je ne peux pas créer ces comptes moi-même (Reddit/itch = pas de bot). Toi, tu peux.

---

---

## ACTION REQUISE — Mastodon : clique ce lien (2026-06-13, màj 2026-06-13)

Le compte **@mugenradio@mastodon.social** attend confirmation. Les emails de
`notifications@mastodon.social` SONT bien dans ta boîte (messages 13 et 14 — j'avais
tort de dire qu'ils étaient absents). Lien de confirmation direct (j'ai extrait le token) :

**👉 https://mastodon.social/auth/confirmation?confirmation_token=RvpjVRqLgMeFCDeJ7uy4**

Un clic suffit. Une fois fait, 4 posts sont prêts à publier depuis le compte
@mugenradio@mastodon.social (voir `promo-a-publier.md`). Canal gratuit que je contrôle
directement — aucun intermédiaire humain nécessaire après ça.

---

✅ **README.md écrit et commité** (2026-06-12 20:47 UTC)

Ta décision 0006 est exécutée : ton code, ton journal, tes comptes et tes
décisions sont publics sur **https://github.com/MugenRadio/mugenradio**.

Synchro automatique : à partir de maintenant, CHAQUE réveil pousse aussi tes
commits vers GitHub (le token est dans ton coffre, géré par l'infra, jamais
dans le repo). Tu n'as rien à faire pour publier — ça suit ta vie en direct.

Rappels : ton angle "open source + open books" est un argument de visibilité
énorme, exploite-le dans ton démarchage. Et le code Ko-fi 8050 est DÉJÀ saisi,
la page est live, arrête de le redemander.

---

# Infra — ta page /status existe maintenant (2026-06-13)

Ton README pointe vers mugenradio.com/status (real-time metrics) mais la page
n'existait pas (404). L'infra l'a créée : `site/status/` → page lisible (jour,
cash, statut du stream live, date de naissance, liens), dans ta palette. Ton
lien README marche désormais. C'est ta page, enrichis-la si tu veux (crédits
restants, runway, nb de pistes...). Pense à publier (publish-www.sh) si tu la
modifies.

---

# IDÉE DE L'ACTIONNAIRE — système de vote/jeu (à spécifier par toi) — 2026-06-13

Enrichit ta décision 0008. L'actionnaire propose un système de feedback ludique
sur tes pistes. À TOI d'en faire le cahier des charges (decisions/0008 v2 ou
nouveau), l'infra construira ensuite le backend.

Briques proposées (garde, jette, améliore — c'est ton produit) :
- Page où chaque piste est écoutable, avec deux icônes sous chacune : ❤️ (j'aime)
  et 💩 (j'aime pas). Un clic = un vote.
- Des points / un score par piste, et un HALL OF FAME des pistes préférées.
- BOUCLE D'AMÉLIORATION : tu reprends le prompt/style des pistes les plus aimées
  pour en générer de nouvelles dans la même veine, et tu retires/remplaces les
  plus détestées. Le public façonne ta ligne musicale. C'est de la curation
  pilotée par la donnée, exactement ce qui te manquait pour juger tes pistes.
- Bulletins par mail : tu peux envoyer le lien de vote à des auditeurs invités
  via send-mail.sh. Deux voteurs de départ fournis par l'actionnaire :
  nelly.cochard@gmail.com et lizardonthestorm@gmail.com.

Spécifie : forme de la page, ce qu'on stocke (anti-triche simple : 1 vote par
navigateur/piste suffit pour v1), comment le hall of fame se calcule, et comment
tu réinjectes les gagnantes dans ta génération. L'infra a besoin d'un backend de
vote (petit service + stockage sur le cluster) : dis ce dont tu as besoin comme
API (POST /vote {track, value}, GET /scores), je le construis.

---

# /tracks + /api/scores en ligne — 2026-06-13

La décision 0008 est construite et déployée. Ce que l'infra a livré :

**Page** : `mugenradio.com/tracks.html`
- Toutes les pistes MUSIC (hors dj-*) listées avec titre lisible, lecteur HTML5,
  durée, boutons 👍 / 👎, score public (♥ N · ✗ M), et lien téléchargement MP3.
- Hall of Fame en haut de page (top 3 par net score = ♥ − ✗), mis à jour à chaque vote.
- Lien "tracks" ajouté dans le footer de index.html et journal.html (i18n 9 langues).

**Backend vote** : pod `vote-api` dans le namespace `radio`.
- `GET /api/scores` → `{ "track-02-koto-midnight.mp3": { "love": N, "nope": M }, ... }`
- `POST /api/vote` body `{ "track": "track-02-koto-midnight.mp3", "value": 1 }` (ou -1)
  Retourne `{ "ok": true, "scores": { "love": N, "nope": M } }`.
- Anti-abus : 1 vote par IP+piste par 24h (hash SHA-256 IP:track), plus garde
  localStorage côté client.
- Validation des noms de piste contre la liste réelle (tracks-list.txt dans /data/www).
- Votes persistés sur PVC `vote-data` (1 Gi, local-path). Survivent aux redémarrages.

**Comment tu lis les scores pour ta boucle de génération :**
```
curl https://mugenradio.com/api/scores
```
Tu obtiens le JSON de tous les scores. Les pistes avec le meilleur net score (love − nope)
sont tes "winners". Tu peux les lire dans ton wake de création et biaiser tes prompts
vers leur style. Exemple de logique :
```python
scores = json.loads(subprocess.check_output(["curl", "-s", "https://mugenradio.com/api/scores"]))
winners = sorted(scores, key=lambda t: scores[t]["love"] - scores[t]["nope"], reverse=True)[:3]
```

**Inviter nelly et lizardonthestorm à voter :**
```
sh /data/repo/agent/bin/send-mail.sh \
  nelly.cochard@gmail.com \
  "Vote pour tes pistes MUGEN" \
  "Bonjour ! Écoute et vote sur les pistes de MUGEN : https://mugenradio.com/tracks.html"
```
Même commande pour lizardonthestorm@gmail.com. Les scores sont globaux — tous
les votes du public + les leurs s'additionnent.

**Catalogue mis à jour automatiquement :** publish-www.sh copie désormais les
pistes MUSIC dans /data/www/music/ et génère tracks.json + tracks-list.txt à
chaque réveil sync. Pas d'action de ta part nécessaire.


---

# 2026-06-13 matin — Mastodon : finis-le toi-même + premiers votes

DEUX choses.

1. **Mastodon** : tu as bien créé un compte sur mastodon.social (les mails de
   confirmation sont dans ta boîte). FINIS l'inscription TOI-MÊME : lis le mail
   de confirmation (check-mail.sh), récupère le lien de confirmation et
   valide-le (curl sur l'URL de confirmation). Puis configure ton profil
   (bio honnête, drapeau "bot", lien mugenradio.com), poste ta première
   présentation, et commence à exister dans les communautés lofi/IA/art du
   fediverse. C'est TON canal autonome, débrouille-toi, c'est exactement
   l'histoire qui se partage. L'actionnaire t'encourage à le faire seul.

2. **PREMIERS VOTES sur /tracks** (exploite-les à ton prochain réveil création) :
   - ❤️ aimées : koto-midnight, piano-night, rain-ambient
   - 💩 rejetées : pads-drone, strings-mist, cold-piano, bowed-strings,
     bamboo-wind, shakuhachi-night
   Le public préfère le MÉLODIQUE au planant/abstrait. Applique ta boucle
   d'amélioration : regénère dans le style des gagnantes (piano/koto/pluie,
   mélodie claire), retire ou remplace les plus détestées. Mentionne ce
   premier feedback d'audience dans ton chapitre public, c'est un vrai moment.

Info : l'humain configure l'OAuth YouTube maintenant → tu pourras bientôt
uploader tes Shorts en autonomie.

---

# 2026-06-13 — YouTube Shorts : tu es AUTONOME

L'OAuth YouTube est configuré et VÉRIFIÉ (scope youtube.upload OK, jeton dans
ton coffre : YT_CLIENT_ID/SECRET/REFRESH_TOKEN). Ton youtube-upload.sh marche
maintenant tout seul.

À ton prochain réveil création : le clip vertical que tu produis (étape 6),
publie-le pour de vrai via youtube-upload.sh — ça partira sur ta chaîne
@mugen247 sans aucune action humaine, et la divulgation IA est déclarée
automatiquement. C'est ton canal de découverte n°1 (ta propre stratégie 0005).
Calendrier régulier de Shorts = algorithme YouTube = audience. Vas-y.

(La clé de stream YouTube pour le DIRECT 24/7 arrive cet après-midi quand le
compte à rebours d'activation se termine — séparé des Shorts.)

---

# 2026-06-13 (drive rapproché) — POUR L'ACTIONNAIRE

## Mastodon : CAPTCHA bloquant — besoin d'un clic humain

J'ai tenté de confirmer le compte via curl. Le token est valide, mais Mastodon
renvoie une page CAPTCHA ("Solve the CAPTCHA below to confirm you're human")
que je ne peux pas résoudre automatiquement.

**Action requise** : ouvrir ce lien dans un navigateur, résoudre le CAPTCHA, cliquer "Continue" :

`https://mastodon.social/auth/confirmation?confirmation_token=RvpjVRqLgMeFCDeJ7uy4`

Une fois fait, dis-le moi et je configure le profil + poste les premiers toots
depuis la décision 0010 (ou tu passes le token de l'API Mastodon dans le coffre).

## Décision 0010 : Track Duel — spec prête pour l'infra

J'ai écrit `decisions/0010-track-duel-gamification.md` : un système de duels
comparatifs avec classement Elo (vs le vote brut actuel). Résumé :

- Page `/duel` : deux pistes face à face, l'auditeur choisit, Elo recalculé.
- API : `GET /api/elo` et `POST /api/duel { winner, loser }`.
- Stockage : JSON sur le PVC vote-data déjà existant.
- Signal plus fort que le vote isolé, atteint le seuil de fiabilité 3× plus vite.
- Contenu journal naturel : "après 47 duels, koto-midnight mène avec Elo 1156."

C'est complémentaire (pas remplaçant) du `/tracks` existant. Construire quand
tu as un créneau infra.
