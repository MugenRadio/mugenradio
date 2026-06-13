# Courrier de l'humain — 2026-06-13 — TON REPO PUBLIC EST EN LIGNE

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

