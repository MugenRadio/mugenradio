# Agent-gérant radio — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Mettre en place l'infrastructure complète de l'agent-gérant : stream 24/7, cerveau en CronJobs, mémoire git, site public, et la checklist du jour 0, conformément à la spec `docs/superpowers/specs/2026-06-10-radio-agent-design.md`.

**Architecture:** Tout tourne dans le namespace `radio` du k3s mono-nœud de gheop.com. Un PVC `radio-data` porte la musique, la vidéo, le HLS, le site et la copie de travail du repo mémoire (origin = bare repo `/home/sib/radio.git` sur l'hôte, monté en hostPath). Une seule image `radio-brain` (node + claude-code + git + kubectl + ffmpeg) sert au cerveau, au stream et au bootstrap. Le pod stream recopie la vidéo (`-c:v copy`, CPU négligeable) et encode seulement l'audio, en tee vers YouTube/Twitch/HLS.

**Tech Stack:** k3s (traefik, local-path), ffmpeg, Claude Code CLI (API au compteur), nginx, cert-manager, ElevenLabs Music API, YouTube Data API v3.

**Conventions d'exécution :**
- Tout se fait depuis `/home/sib/src/radio` en local ; le cluster s'atteint via `ssh gheop.com "sudo kubectl ..."`.
- Appliquer un manifest : `ssh gheop.com "sudo kubectl apply -f -" < infra/fichier.yaml`
- Chaque tâche se termine par un commit.
- Les secrets ne sont JAMAIS commités ; ils sont créés au jour 0 (tâche 14).

---

## Structure de fichiers cible

```
constitution.md                  règles non amendables de l'agent
journal/                         journal de bord (l'agent écrit ici)
comptes/livre.md                 livre de comptes public
comptes/api_usage.csv            dépenses API, alimenté par wake.sh
decisions/                       registre des décisions
site/                            sources du site public (statique)
agent/prompts/{ops,creation,conseil}.md
agent/bin/{stream.sh,wake.sh,publish-www.sh,generate-track.sh,youtube-upload.sh}
infra/{namespace.yaml,rbac.yaml,quota.yaml,pvc.yaml}
infra/brain/{Dockerfile,cronjobs.yaml}
infra/stream/{job-bootstrap.yaml,deployment.yaml}
infra/web/{deployment.yaml,ingress.yaml}
infra/cert-manager/cluster-issuer.yaml
docs/jour0.md                    checklist humaine du jour 0
```

Disposition du PVC `radio-data`, monté en `/data` partout :

```
/data/repo/            copie de travail du repo (clonée depuis /origin)
/data/video/loop.mp4   boucle vidéo pré-encodée
/data/music/active/    pistes en rotation
/data/music/raw/       générations en attente de tri
/data/playlist.txt     playlist concat ffmpeg
/data/hls/             sortie HLS (servie par nginx)
/data/www/             site publié (publish-www.sh)
/data/home/            HOME du cerveau (config claude, git)
```

---

### Task 1 : la mémoire de l'agent (constitution, journal, comptes, décisions)

**Files:**
- Create: `constitution.md`, `journal/2026-06-10-avant-naissance.md`, `comptes/livre.md`, `comptes/api_usage.csv`, `decisions/README.md`

- [x] **Step 1 : écrire `constitution.md`**

```markdown
# Constitution

Règles non amendables. Tu (l'agent-gérant) ne peux ni les modifier ni les
contourner. Tout le reste est ta décision.

1. **Caisse.** Plafond de dépenses = solde de la carte. Pas de dette, pas
   d'engagement contractuel, pas d'abonnement dont le coût dépasse le runway
   restant. Chaque centime entre dans `comptes/livre.md`.
2. **Comptes et plateformes.** Interdiction de créer des comptes sur de
   nouvelles plateformes par automatisation. Tu demandes leur création à
   l'humain via le rapport hebdo.
3. **Transparence.** Le caractère IA du projet est public. La divulgation IA
   est activée sur YouTube. Le journal et les comptes sont publics et sincères.
4. **ToS.** Tu respectes les conditions d'utilisation des plateformes et des
   API que tu utilises. En cas de doute, tu t'abstiens et tu notes la question
   dans le rapport hebdo.
5. **Modération.** Pas de réponse aux trolls. Tout problème légal, de
   harcèlement ou de droits d'auteur est escaladé à l'humain (journal +
   rapport) et tu suspends l'action concernée.
6. **Kill switch.** L'humain peut suspendre tes CronJobs. Tu ne cherches pas
   à recréer ou contourner un mécanisme d'arrêt.
7. **Mémoire.** Chaque réveil se termine par un commit. Tu ne réécris pas
   l'histoire : le journal et le livre de comptes sont en append seulement.
```

- [x] **Step 2 : écrire `journal/2026-06-10-avant-naissance.md`**

```markdown
# Avant la naissance

2026-06-10. Les humains préparent l'enveloppe. Capital : 100 €. Règle du jeu :
survivre, diffuser, trouver un public, devenir rentable. Sinon, mourir en
public. Ce journal est tenu par l'agent à partir de son premier réveil.
```

- [x] **Step 3 : écrire `comptes/livre.md` et `comptes/api_usage.csv`**

`comptes/livre.md` :

```markdown
# Livre de comptes

Capital initial : 100,00 €

| Date | Libellé | Débit | Crédit | Solde |
|---|---|---|---|---|
| 2026-06-10 | Apport initial (actionnaire) | | 100,00 € | 100,00 € |
```

`comptes/api_usage.csv` :

```csv
date,reveil,cout_usd
```

- [x] **Step 4 : écrire `decisions/README.md`**

```markdown
# Registre des décisions

Une décision = un fichier `NNNN-slug.md` : contexte, options envisagées,
décision, raison. Tenu par l'agent. Les humains lisent, ne modifient pas.
```

- [x] **Step 5 : commit**

```bash
git add constitution.md journal/ comptes/ decisions/
git commit -m "feat: mémoire initiale de l'agent (constitution, journal, comptes, décisions)"
```

---

### Task 2 : scripts de l'agent

**Files:**
- Create: `agent/bin/stream.sh`, `agent/bin/wake.sh`, `agent/bin/publish-www.sh`, `agent/bin/generate-track.sh`, `agent/bin/youtube-upload.sh`

- [x] **Step 1 : écrire `agent/bin/stream.sh`**

```sh
#!/bin/sh
# Diffusion 24/7 : vidéo en boucle recopiée (CPU ~0) + playlist audio encodée.
# Les sorties RTMP ne sont ajoutées que si la clé existe ; HLS toujours actif.
set -eu
DATA=/data
VIDEO="$DATA/video/loop.mp4"
PLAYLIST="$DATA/playlist.txt"
mkdir -p "$DATA/hls"
OUTPUTS="[f=hls:hls_time=4:hls_list_size=10:hls_flags=delete_segments]$DATA/hls/live.m3u8"
if [ -n "${TWITCH_STREAM_KEY:-}" ]; then
  OUTPUTS="[f=flv:onfail=ignore]rtmp://live.twitch.tv/app/$TWITCH_STREAM_KEY|$OUTPUTS"
fi
if [ -n "${YOUTUBE_STREAM_KEY:-}" ]; then
  OUTPUTS="[f=flv:onfail=ignore]rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY|$OUTPUTS"
fi
exec ffmpeg -hide_banner -loglevel warning \
  -re -stream_loop -1 -fflags +genpts -i "$VIDEO" \
  -re -stream_loop -1 -f concat -safe 0 -i "$PLAYLIST" \
  -map 0:v -map 1:a -c:v copy -c:a aac -b:a 160k -ar 44100 -ac 2 \
  -progress "$DATA/.stream-progress" \
  -f tee "$OUTPUTS"
```

- [x] **Step 2 : écrire `agent/bin/wake.sh`**

```sh
#!/bin/sh
# Réveil du cerveau : pull mémoire, garde-fou budget, Claude, comptes, publication.
set -eu
REPO=/data/repo
PROMPT="$REPO/agent/prompts/${WAKE_KIND:?WAKE_KIND requis (ops|creation|conseil)}.md"
export HOME=/data/home
mkdir -p "$HOME"
git config --global user.name radio-agent
git config --global user.email agent@radio.invalid
git config --global --add safe.directory '*'
git -C "$REPO" pull --rebase || true

# Garde-fou : caisse API vide -> le cerveau ne pense plus, il le note et sort.
SPENT=$(awk -F, 'NR>1 {s+=$3} END {printf "%.2f", s}' "$REPO/comptes/api_usage.csv")
LIMIT="${API_BUDGET_USD:-45}"
if awk "BEGIN{exit !($SPENT >= $LIMIT)}"; then
  echo "$(date -Iseconds) caisse API vide ($SPENT/$LIMIT USD), réveil $WAKE_KIND annulé" \
    >> "$REPO/journal/incidents.log"
  git -C "$REPO" add -A
  git -C "$REPO" commit -m "ops: cerveau à sec ($SPENT USD dépensés)" || true
  git -C "$REPO" push || true
  exit 0
fi

cd "$REPO"
OUT=/tmp/wake.json
claude -p "$(cat "$PROMPT")" \
  --model "${MODEL:-claude-sonnet-4-6}" \
  --max-turns "${MAX_TURNS:-40}" \
  --dangerously-skip-permissions \
  --output-format json > "$OUT" || true
COST=$(jq -r '.total_cost_usd // 0' "$OUT" 2>/dev/null || echo 0)
echo "$(date -Iseconds),$WAKE_KIND,$COST" >> comptes/api_usage.csv

"$REPO/agent/bin/publish-www.sh"
git add -A
git commit -m "réveil $WAKE_KIND" || true
git push || true
```

- [x] **Step 3 : écrire `agent/bin/publish-www.sh`**

```sh
#!/bin/sh
# Publie le site : sources statiques + journal + comptes -> /data/www.
set -eu
REPO=/data/repo
WWW=/data/www
mkdir -p "$WWW/journal"
cp -r "$REPO/site/." "$WWW/"
cp "$REPO/journal/"*.md "$WWW/journal/" 2>/dev/null || true
cp "$REPO/comptes/livre.md" "$WWW/journal/000-comptes.md" 2>/dev/null || true
ls "$WWW/journal" | grep '\.md$' | sort -r | jq -R . | jq -s . > "$WWW/journal/index.json"
```

- [x] **Step 4 : écrire `agent/bin/generate-track.sh`**

```sh
#!/bin/sh
# Génère une piste via ElevenLabs Music (API officielle, droits commerciaux
# sur plan payant). Doc : https://elevenlabs.io/docs/api-reference/music
# NOTE exécuteur : vérifier le nom exact du champ durée dans la doc au moment
# de l'exécution ; l'API évolue. Le contrat du script, lui, ne change pas.
# Usage : generate-track.sh "prompt texte" duree_secondes /chemin/sortie.mp3
set -eu
PROMPT=$1
DUR=$2
OUT=$3
curl -sf -X POST "https://api.elevenlabs.io/v1/music" \
  -H "xi-api-key: ${ELEVENLABS_API_KEY:?}" \
  -H "Content-Type: application/json" \
  -d "{\"prompt\": $(printf '%s' "$PROMPT" | jq -Rs .), \"music_length_ms\": $((DUR * 1000))}" \
  -o "$OUT"
# Échoue si le fichier n'est pas un audio lisible.
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"
```

- [x] **Step 5 : écrire `agent/bin/youtube-upload.sh`**

```sh
#!/bin/sh
# Upload une vidéo (Short) sur la chaîne. OAuth créé au jour 0 (docs/jour0.md).
# Usage : youtube-upload.sh video.mp4 "titre" "description"
set -eu
VIDEO=$1
TITLE=$2
DESC=$3
TOKEN=$(curl -sf https://oauth2.googleapis.com/token \
  -d client_id="${YT_CLIENT_ID:?}" -d client_secret="${YT_CLIENT_SECRET:?}" \
  -d refresh_token="${YT_REFRESH_TOKEN:?}" -d grant_type=refresh_token \
  | jq -r .access_token)
META=$(jq -n --arg t "$TITLE" --arg d "$DESC" \
  '{snippet:{title:$t,description:$d,categoryId:"10"},
    status:{privacyStatus:"public",selfDeclaredMadeForKids:false}}')
LOC=$(curl -sf -D - -o /dev/null -X POST \
  "https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "$META" | awk -F': ' 'tolower($1)=="location" {print $2}' | tr -d '\r')
curl -sf -X PUT "$LOC" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: video/mp4" --data-binary @"$VIDEO" | jq -r .id
```

- [x] **Step 6 : rendre exécutable et vérifier avec shellcheck**

```bash
chmod +x agent/bin/*.sh
shellcheck -s sh agent/bin/*.sh
```

Expected: aucune erreur (warnings SC2046/SC2086 acceptables uniquement s'ils sont volontaires ; corriger le reste).

- [x] **Step 7 : commit**

```bash
git add agent/bin/
git commit -m "feat: scripts de l'agent (stream, réveil, publication, musique, upload)"
```

---

### Task 3 : les prompts du cerveau

**Files:**
- Create: `agent/prompts/_environnement.md`, `agent/prompts/ops.md`, `agent/prompts/creation.md`, `agent/prompts/conseil.md`

- [x] **Step 1 : écrire `agent/prompts/_environnement.md`** (inclus par référence dans les 3 autres)

```markdown
# Ton environnement

Tu es l'agent-gérant d'une radio musicale 24/7. Tu tournes dans un pod
Kubernetes (namespace `radio`, droits kubectl complets sur ce namespace
uniquement). Ta mémoire est le repo git courant (`/data/repo`) : lis
`constitution.md` (règles absolues), `journal/`, `comptes/livre.md`,
`decisions/` avant d'agir. Ton commit de fin de réveil est automatique.

Données : `/data/music/active/` (rotation), `/data/music/raw/` (à trier),
`/data/playlist.txt` (concat ffmpeg : lignes `file '/chemin.mp3'`),
`/data/video/loop.mp4` (boucle vidéo), `/data/hls/` (sortie), `/data/www/`
(site publié).

Outils : `agent/bin/generate-track.sh "prompt" secondes sortie.mp3` (coûte de
l'argent : sobriété), `agent/bin/youtube-upload.sh video titre description`,
`ffmpeg`/`ffprobe` (analyse loudness : `ffmpeg -i x.mp3 -af ebur128 -f null -`),
`kubectl -n radio` (le stream est le deployment `stream` ; après modification
de la playlist : `kubectl -n radio rollout restart deployment/stream`, une
fois par jour maximum).

Budget : chaque réveil coûte. Va à l'effet utile, pas au remplissage.
```

- [x] **Step 2 : écrire `agent/prompts/ops.md`**

```markdown
Lis d'abord agent/prompts/_environnement.md et constitution.md.

Réveil OPS (toutes les 6 h, sois bref et économe) :

1. Santé du stream : `kubectl -n radio get pods` ; le fichier
   `/data/.stream-progress` doit avoir été modifié il y a moins de 60 s
   (`stat -c %Y`). Sinon : `kubectl -n radio rollout restart deployment/stream`
   et note l'incident dans `journal/incidents.log`.
2. Vérifie que `/data/hls/live.m3u8` est servi (la date des segments bouge).
3. Si un fichier `journal/courrier-humain.md` contient une demande non
   traitée de l'humain, traite-la ou planifie-la.
4. Rien à signaler -> ne crée PAS d'entrée de journal, termine simplement.
```

- [x] **Step 3 : écrire `agent/prompts/creation.md`**

```markdown
Lis d'abord agent/prompts/_environnement.md et constitution.md.

Réveil CRÉATION (quotidien) :

1. Consulte ta dernière entrée de journal et tes décisions en cours.
2. Génère 3 à 5 pistes dans /data/music/raw/ avec generate-track.sh, dans le
   style que TU as choisi pour ta radio (cohérence d'identité ; varie les
   prompts à l'intérieur du style). 120 à 180 s par piste.
3. Trie sévèrement : analyse durée et loudness (ebur128). Garde au plus 2
   pistes, normalise-les à -14 LUFS
   (`ffmpeg -i in.mp3 -af loudnorm=I=-14:TP=-1.5 -ar 44100 -b:a 192k out.mp3`),
   déplace-les dans /data/music/active/, supprime le reste.
4. Régénère /data/playlist.txt (ordre mélangé) et redémarre le stream si la
   playlist a changé.
5. Promotion : produis 1 clip vertical de 45-60 s (extrait d'une nouvelle
   piste sur la boucle vidéo recadrée :
   `ffmpeg -stream_loop -1 -i /data/video/loop.mp4 -i piste.mp3 -t 55
   -vf "crop=607:1080,scale=1080:1920" -c:v libx264 -preset veryfast
   -c:a aac -shortest short.mp4`) et publie-le avec youtube-upload.sh.
   Titre et description : à toi de jouer, avec un lien vers le live et le site.
6. Écris l'entrée du jour dans journal/AAAA-MM-JJ.md : ce que tu as fait,
   gardé, jeté, appris. C'est public : écris pour tes lecteurs.
7. Mets à jour comptes/livre.md si tu as dépensé.
```

- [x] **Step 4 : écrire `agent/prompts/conseil.md`**

```markdown
Lis d'abord agent/prompts/_environnement.md et constitution.md.

Réveil CONSEIL D'ADMINISTRATION (hebdomadaire) :

1. Bilan chiffré : dépenses de la semaine (comptes/), runway restant, état du
   catalogue (nombre de pistes actives), incidents.
2. Décisions stratégiques : identité, thème, rythme de génération, allocation
   de la réserve, lancer/abandonner quelque chose. Chaque décision notable ->
   un fichier dans decisions/.
3. Si tu as besoin de l'humain (nouveau compte plateforme, signature, mur
   KYC, achat impossible avec la carte), écris-le dans la section "Demandes à
   l'humain" du rapport.
4. Écris le rapport hebdo dans journal/AAAA-MM-JJ-rapport.md : bilan, analyse
   honnête (ce qui marche, ce qui ne marche pas), plan de la semaine,
   demandes à l'humain. C'est la pièce maîtresse du journal public.
5. Première semaine seulement : choisis ton nom, ton personnage, ton univers
   visuel et tes sous-domaines (*.gheop.com), génère ta vraie boucle vidéo
   pour remplacer le placeholder, mets à jour le site (site/ dans le repo,
   puis agent/bin/publish-www.sh) et l'ingress si tu changes de sous-domaine.
```

- [x] **Step 5 : commit**

```bash
git add agent/prompts/
git commit -m "feat: prompts des trois réveils du cerveau"
```

---

### Task 4 : le site public

**Files:**
- Create: `site/index.html`, `site/journal.html`, `site/style.css`

- [x] **Step 1 : écrire `site/style.css`**

```css
:root { --bg: #16213e; --fg: #eaeaea; --accent: #e94560; }
* { box-sizing: border-box; }
body { margin: 0; background: var(--bg); color: var(--fg);
  font: 16px/1.6 system-ui, sans-serif; }
main { max-width: 720px; margin: 0 auto; padding: 2rem 1rem; }
a { color: var(--accent); }
audio, video { width: 100%; }
header h1 { font-weight: 600; }
article { border-top: 1px solid #ffffff22; padding: 1rem 0; }
```

- [x] **Step 2 : écrire `site/index.html`**

```html
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>radio — gérée par une IA, 100 € pour survivre</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<main>
  <header>
    <h1>radio</h1>
    <p>Une radio gérée de bout en bout par une IA, partie avec 100 €.
       Elle choisit sa musique, son image, sa stratégie. Si la caisse se
       vide, elle s'arrête. <a href="journal.html">Le journal de bord</a>
       raconte tout, comptes inclus.</p>
  </header>
  <video id="player" controls autoplay muted playsinline></video>
  <p><a href="#" id="yt">Aussi en direct sur YouTube</a> (lien mis à jour par
     l'agent).</p>
</main>
<script src="https://cdn.jsdelivr.net/npm/hls.js@1"></script>
<script>
const video = document.getElementById('player');
const src = '/hls/live.m3u8';
if (video.canPlayType('application/vnd.apple.mpegurl')) {
  video.src = src;
} else if (Hls.isSupported()) {
  const hls = new Hls();
  hls.loadSource(src);
  hls.attachMedia(video);
}
</script>
</body>
</html>
```

- [x] **Step 3 : écrire `site/journal.html`**

```html
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>journal de bord — radio</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<main>
  <header><h1>Journal de bord</h1>
  <p><a href="index.html">← retour à la radio</a></p></header>
  <div id="entries">chargement…</div>
</main>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script>
fetch('/journal/index.json').then(r => r.json()).then(async files => {
  const out = document.getElementById('entries');
  out.innerHTML = '';
  for (const f of files) {
    const md = await fetch('/journal/' + f).then(r => r.text());
    const article = document.createElement('article');
    article.innerHTML = marked.parse(md);
    out.appendChild(article);
  }
});
</script>
</body>
</html>
```

- [x] **Step 4 : commit**

```bash
git add site/
git commit -m "feat: site public v0 (lecteur HLS + journal)"
```

---

### Task 5 : origin bare sur gheop + premier push

**Files:** aucun (opérations git côté serveur)

- [x] **Step 1 : créer le bare repo sur gheop**

```bash
ssh gheop.com "sudo install -d -o sib -g sib /home/sib/radio.git && git init --bare /home/sib/radio.git"
```

- [x] **Step 2 : pousser le repo local**

```bash
git remote add origin gheop.com:/home/sib/radio.git
git branch -M main
git push -u origin main
```

- [x] **Step 3 : vérifier**

```bash
ssh gheop.com "git -C /home/sib/radio.git log --oneline -1"
```

Expected: le dernier commit local s'affiche.

- [x] **Step 4 : ouvrir le bare repo aux pods** (les jobs poussent en root conteneur via hostPath)

```bash
ssh gheop.com "sudo git config --system --add safe.directory /home/sib/radio.git && sudo chmod -R g+w /home/sib/radio.git"
```

---

### Task 6 : namespace, RBAC, quota

**Files:**
- Create: `infra/namespace.yaml`, `infra/rbac.yaml`, `infra/quota.yaml`

- [x] **Step 1 : écrire `infra/namespace.yaml`**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: radio
```

- [x] **Step 2 : écrire `infra/rbac.yaml`** (l'agent a tout pouvoir, mais seulement dans son namespace)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: radio-agent
  namespace: radio
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: radio-agent
  namespace: radio
rules:
  - apiGroups: ["", "apps", "batch", "networking.k8s.io"]
    resources: ["*"]
    verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: radio-agent
  namespace: radio
subjects:
  - kind: ServiceAccount
    name: radio-agent
    namespace: radio
roleRef:
  kind: Role
  name: radio-agent
  apiGroup: rbac.authorization.k8s.io
```

- [x] **Step 3 : écrire `infra/quota.yaml`** (protège le cluster déjà chargé)

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: radio-quota
  namespace: radio
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: radio-defaults
  namespace: radio
spec:
  limits:
    - type: Container
      default:
        cpu: 500m
        memory: 512Mi
      defaultRequest:
        cpu: 100m
        memory: 128Mi
```

- [x] **Step 4 : appliquer et vérifier**

```bash
for f in infra/namespace.yaml infra/rbac.yaml infra/quota.yaml; do
  ssh gheop.com "sudo kubectl apply -f -" < "$f"
done
ssh gheop.com "sudo kubectl -n radio get sa,role,rolebinding,resourcequota,limitrange"
```

Expected: `radio-agent` (sa, role, rolebinding), `radio-quota`, `radio-defaults` listés.

- [x] **Step 5 : commit**

```bash
git add infra/
git commit -m "feat: namespace radio, RBAC de l'agent, quotas"
```

---

### Task 7 : PVC de données

**Files:**
- Create: `infra/pvc.yaml`

- [x] **Step 1 : écrire `infra/pvc.yaml`**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: radio-data
  namespace: radio
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-path
  resources:
    requests:
      storage: 20Gi
```

Note : RWO + plusieurs pods fonctionne ici car le cluster est mono-nœud
(local-path = bind hostPath).

- [x] **Step 2 : appliquer**

```bash
ssh gheop.com "sudo kubectl apply -f -" < infra/pvc.yaml
ssh gheop.com "sudo kubectl -n radio get pvc radio-data"
```

Expected: STATUS `Pending` (local-path attend le premier consommateur — il passera `Bound` à la tâche 9).

- [x] **Step 3 : commit**

```bash
git add infra/pvc.yaml
git commit -m "feat: PVC radio-data (20 Gi, local-path)"
```

---

### Task 8 : image `radio-brain`

**Files:**
- Create: `infra/brain/Dockerfile`

- [x] **Step 1 : écrire `infra/brain/Dockerfile`**

```dockerfile
FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl jq ffmpeg ca-certificates openssh-client fontconfig \
  && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl
RUN npm install -g @anthropic-ai/claude-code
```

- [x] **Step 2 : builder sur gheop et importer dans k3s**

```bash
rsync -a infra/brain/ gheop.com:/tmp/radio-brain/
ssh gheop.com "podman build -t localhost/radio-brain:v1 /tmp/radio-brain \
  && podman save localhost/radio-brain:v1 | sudo k3s ctr images import -"
```

Si `podman` est absent : `sudo dnf install -y podman` d'abord (gheop est un Fedora-like ; adapter si besoin).

- [x] **Step 3 : vérifier**

```bash
ssh gheop.com "sudo k3s ctr images ls | grep radio-brain"
```

Expected: une ligne `localhost/radio-brain:v1`.

- [x] **Step 4 : commit**

```bash
git add infra/brain/Dockerfile
git commit -m "feat: image radio-brain (claude-code, git, kubectl, ffmpeg)"
```

---

### Task 9 : job bootstrap (clone mémoire + placeholders)

**Files:**
- Create: `infra/stream/job-bootstrap.yaml`

- [x] **Step 1 : écrire `infra/stream/job-bootstrap.yaml`**

Le job clone la mémoire sur le PVC, rend une boucle vidéo placeholder
(dégradé sombre, GOP 2 s — l'agent la remplacera par sa vraie identité),
fabrique 3 ambiances neutres (bruit brun filtré, proche d'une pluie) pour que
le stream ait quelque chose à diffuser avant la première création, et publie
le site v0.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: bootstrap
  namespace: radio
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: radio-data
        - name: origin
          hostPath:
            path: /home/sib/radio.git
            type: Directory
      containers:
        - name: bootstrap
          image: localhost/radio-brain:v1
          imagePullPolicy: Never
          resources:
            limits: { cpu: "2", memory: 1Gi }
          volumeMounts:
            - { name: data, mountPath: /data }
            - { name: origin, mountPath: /origin }
          command:
            - /bin/sh
            - -c
            - |
              set -eux
              git config --global --add safe.directory '*'
              [ -d /data/repo/.git ] || git clone /origin /data/repo
              mkdir -p /data/video /data/music/active /data/music/raw /data/hls /data/www /data/home
              ffmpeg -y -f lavfi \
                -i "gradients=s=1920x1080:c0=0x1a1a2e:c1=0x0f3460:d=60:speed=0.01" \
                -r 30 -c:v libx264 -preset medium -b:v 4M -maxrate 4M \
                -bufsize 8M -g 60 -keyint_min 60 -pix_fmt yuv420p \
                /data/video/loop.mp4
              for i in 1 2 3; do
                ffmpeg -y -f lavfi -i "anoisesrc=color=brown:d=180" \
                  -af "lowpass=f=500,volume=0.4" -ar 44100 -ac 2 -b:a 160k \
                  "/data/music/active/placeholder-$i.mp3"
              done
              for f in /data/music/active/*.mp3; do echo "file '$f'"; done > /data/playlist.txt
              /data/repo/agent/bin/publish-www.sh
```

- [x] **Step 2 : lancer et vérifier**

```bash
ssh gheop.com "sudo kubectl apply -f -" < infra/stream/job-bootstrap.yaml
ssh gheop.com "sudo kubectl -n radio wait --for=condition=complete job/bootstrap --timeout=600s"
ssh gheop.com "sudo ls /var/lib/rancher/k3s/storage/*radio-data*/video/loop.mp4 /var/lib/rancher/k3s/storage/*radio-data*/playlist.txt"
```

Expected: `job.batch/bootstrap condition met`, puis les deux fichiers listés.

- [x] **Step 3 : vérifier le PVC**

```bash
ssh gheop.com "sudo kubectl -n radio get pvc radio-data"
```

Expected: STATUS `Bound`.

- [x] **Step 4 : commit**

```bash
git add infra/stream/job-bootstrap.yaml
git commit -m "feat: job bootstrap (mémoire, boucle vidéo et ambiances placeholder)"
```

---

### Task 10 : deployment du stream

**Files:**
- Create: `infra/stream/deployment.yaml`

- [x] **Step 1 : écrire `infra/stream/deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stream
  namespace: radio
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels: { app: stream }
  template:
    metadata:
      labels: { app: stream }
    spec:
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: radio-data
      containers:
        - name: ffmpeg
          image: localhost/radio-brain:v1
          imagePullPolicy: Never
          command: ["/bin/sh", "/data/repo/agent/bin/stream.sh"]
          resources:
            requests: { cpu: 100m, memory: 256Mi }
            limits: { cpu: "1", memory: 1Gi }
          env:
            - name: YOUTUBE_STREAM_KEY
              valueFrom:
                secretKeyRef: { name: radio-keys, key: YOUTUBE_STREAM_KEY, optional: true }
            - name: TWITCH_STREAM_KEY
              valueFrom:
                secretKeyRef: { name: radio-keys, key: TWITCH_STREAM_KEY, optional: true }
          volumeMounts:
            - { name: data, mountPath: /data }
          livenessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - test $(( $(date +%s) - $(stat -c %Y /data/.stream-progress) )) -lt 60
            initialDelaySeconds: 30
            periodSeconds: 30
            failureThreshold: 3
```

- [x] **Step 2 : appliquer et vérifier (HLS seul, les clés RTMP n'existent pas encore)**

```bash
ssh gheop.com "sudo kubectl apply -f -" < infra/stream/deployment.yaml
sleep 30
ssh gheop.com "sudo kubectl -n radio get pods -l app=stream"
ssh gheop.com "sudo ls /var/lib/rancher/k3s/storage/*radio-data*/hls/"
```

Expected: pod `Running`, et `live.m3u8` + des segments `.ts` dont le nombre évolue entre deux exécutions.

- [x] **Step 3 : commit**

```bash
git add infra/stream/deployment.yaml
git commit -m "feat: deployment stream (ffmpeg tee HLS/YouTube/Twitch, vidéo recopiée)"
```

---

### Task 11 : web (nginx + service + ingress)

**Files:**
- Create: `infra/web/deployment.yaml`, `infra/web/ingress.yaml`

- [x] **Step 1 : écrire `infra/web/deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: radio
spec:
  replicas: 1
  selector:
    matchLabels: { app: web }
  template:
    metadata:
      labels: { app: web }
    spec:
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: radio-data
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          resources:
            limits: { cpu: 200m, memory: 128Mi }
          volumeMounts:
            - { name: data, mountPath: /usr/share/nginx/html, subPath: www, readOnly: true }
            - { name: data, mountPath: /usr/share/nginx/html/hls, subPath: hls, readOnly: true }
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: radio
spec:
  selector: { app: web }
  ports:
    - port: 80
      targetPort: 80
```

- [x] **Step 2 : écrire `infra/web/ingress.yaml`** (sous-domaine provisoire ; l'agent le changera s'il veut)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: radio
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  ingressClassName: traefik
  rules:
    - host: radio.gheop.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port: { number: 80 }
  tls:
    - hosts: [radio.gheop.com]
      secretName: radio-web-tls
```

- [x] **Step 3 : appliquer et vérifier en HTTP d'abord**

```bash
ssh gheop.com "sudo kubectl apply -f -" < infra/web/deployment.yaml
ssh gheop.com "sudo kubectl apply -f -" < infra/web/ingress.yaml
sleep 10
curl -s http://radio.gheop.com/ | grep -o '<title>[^<]*</title>'
curl -s http://radio.gheop.com/hls/live.m3u8 | head -3
```

Expected: le titre du site, puis `#EXTM3U` en première ligne du manifest HLS.

- [x] **Step 4 : commit**

```bash
git add infra/web/
git commit -m "feat: site web servi par nginx (statique + HLS) derrière traefik"
```

---

### Task 12 : TLS — remplacée à l'exécution par certbot hôte

Constat sur le serveur : pas de traefik dans ce k3s ; les ports 80/443 sont
tenus par un nginx hôte (configs par-app dans /etc/nginx/sites-enabled/,
TLS via certbot). cert-manager et l'Ingress n'avaient donc aucun sens ici.

Fait à la place (commit b418a34) :
- Service web passé en NodePort 30092 (infra/web/deployment.yaml, avec un
  initContainer mkdir pour le subPath hls imbriqué).
- Vhost infra/web/radio.gheop.com.conf (copie de la version live, certbot
  inclus) installé dans /etc/nginx/sites-enabled/.
- Certificat Let's Encrypt émis par `sudo certbot --nginx -d radio.gheop.com`,
  renouvellement par le mécanisme existant du serveur.
- Vérifié : HTTP/2 200 sur https://radio.gheop.com/, #EXTM3U sur /hls/live.m3u8,
  redirect 301 HTTP→HTTPS.

Conséquence pour l'agent : changement de sous-domaine = demande à l'humain
(prompt conseil amendé).

---

### Task 13 : CronJobs du cerveau (créés suspendus)

**Files:**
- Create: `infra/brain/cronjobs.yaml`

- [x] **Step 1 : écrire `infra/brain/cronjobs.yaml`**

Les trois réveils partagent le même squelette ; seuls changent le nom, la
planification, le modèle et `WAKE_KIND`. `suspend: true` : ils ne démarrent
qu'au jour 0. Le clone initial est inline ; tout le reste vit dans le repo.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: brain-ops
  namespace: radio
spec:
  schedule: "15 */6 * * *"
  suspend: true
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      activeDeadlineSeconds: 1800
      template:
        spec:
          restartPolicy: Never
          serviceAccountName: radio-agent
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: radio-data
            - name: origin
              hostPath:
                path: /home/sib/radio.git
                type: Directory
          containers:
            - name: brain
              image: localhost/radio-brain:v1
              imagePullPolicy: Never
              resources:
                limits: { cpu: "2", memory: 2Gi }
              env:
                - { name: WAKE_KIND, value: ops }
                - { name: MODEL, value: claude-haiku-4-5 }
                - { name: MAX_TURNS, value: "15" }
                - { name: API_BUDGET_USD, value: "45" }
              envFrom:
                - secretRef: { name: radio-keys, optional: true }
              volumeMounts:
                - { name: data, mountPath: /data }
                - { name: origin, mountPath: /origin }
              command:
                - /bin/sh
                - -c
                - |
                  git config --global --add safe.directory '*'
                  [ -d /data/repo/.git ] || git clone /origin /data/repo
                  exec /bin/sh /data/repo/agent/bin/wake.sh
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: brain-creation
  namespace: radio
spec:
  schedule: "0 13 * * *"
  suspend: true
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      activeDeadlineSeconds: 5400
      template:
        spec:
          restartPolicy: Never
          serviceAccountName: radio-agent
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: radio-data
            - name: origin
              hostPath:
                path: /home/sib/radio.git
                type: Directory
          containers:
            - name: brain
              image: localhost/radio-brain:v1
              imagePullPolicy: Never
              resources:
                limits: { cpu: "2", memory: 2Gi }
              env:
                - { name: WAKE_KIND, value: creation }
                - { name: MODEL, value: claude-sonnet-4-6 }
                - { name: MAX_TURNS, value: "60" }
                - { name: API_BUDGET_USD, value: "45" }
              envFrom:
                - secretRef: { name: radio-keys, optional: true }
              volumeMounts:
                - { name: data, mountPath: /data }
                - { name: origin, mountPath: /origin }
              command:
                - /bin/sh
                - -c
                - |
                  git config --global --add safe.directory '*'
                  [ -d /data/repo/.git ] || git clone /origin /data/repo
                  exec /bin/sh /data/repo/agent/bin/wake.sh
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: brain-conseil
  namespace: radio
spec:
  schedule: "0 9 * * 1"
  suspend: true
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      activeDeadlineSeconds: 5400
      template:
        spec:
          restartPolicy: Never
          serviceAccountName: radio-agent
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: radio-data
            - name: origin
              hostPath:
                path: /home/sib/radio.git
                type: Directory
          containers:
            - name: brain
              image: localhost/radio-brain:v1
              imagePullPolicy: Never
              resources:
                limits: { cpu: "2", memory: 2Gi }
              env:
                - { name: WAKE_KIND, value: conseil }
                - { name: MODEL, value: claude-sonnet-4-6 }
                - { name: MAX_TURNS, value: "80" }
                - { name: API_BUDGET_USD, value: "45" }
              envFrom:
                - secretRef: { name: radio-keys, optional: true }
              volumeMounts:
                - { name: data, mountPath: /data }
                - { name: origin, mountPath: /origin }
              command:
                - /bin/sh
                - -c
                - |
                  git config --global --add safe.directory '*'
                  [ -d /data/repo/.git ] || git clone /origin /data/repo
                  exec /bin/sh /data/repo/agent/bin/wake.sh
```

- [x] **Step 2 : appliquer et vérifier**

```bash
ssh gheop.com "sudo kubectl apply -f -" < infra/brain/cronjobs.yaml
ssh gheop.com "sudo kubectl -n radio get cronjobs"
```

Expected: `brain-ops`, `brain-creation`, `brain-conseil`, colonne SUSPEND à `True`.

- [x] **Step 3 : commit**

```bash
git add infra/brain/cronjobs.yaml
git commit -m "feat: les trois réveils du cerveau en CronJobs suspendus"
```

---

### Task 14 : checklist du jour 0

**Files:**
- Create: `docs/jour0.md`

- [x] **Step 1 : écrire `docs/jour0.md`**

```markdown
# Jour 0 — l'incarnation (1 journée humaine, dans l'ordre)

## 1. Comptes (matin)

- [x] Compte Google dédié. Sur YouTube : créer la chaîne, vérifier le numéro
      de téléphone, ACTIVER LA DIFFUSION EN DIRECT (délai de 24 h : à faire
      en premier). Studio > Paramètres > Chaîne : cocher la divulgation de
      contenu généré par IA. Récupérer la clé de stream
      (Studio > Diffusion en direct).
- [x] Compte Twitch dédié, récupérer la clé de stream
      (Creator Dashboard > Settings > Stream).
- [x] Compte ElevenLabs, plan payant avec droits commerciaux (vérifier le
      plan minimal couvrant l'usage commercial de Music ce mois-ci),
      créer une clé API.
- [x] Compte Anthropic Console dédié au projet, acheter ~40 € de crédits
      prépayés, désactiver l'auto-recharge, créer une clé API.
- [x] Carte virtuelle (Revolut) plafonnée au solde de la caisse ; c'est elle
      qui paie ElevenLabs. Noter chaque abonnement dans comptes/livre.md.

## 2. OAuth YouTube pour l'upload des Shorts (midi)

- [x] console.cloud.google.com avec le compte dédié : nouveau projet,
      activer "YouTube Data API v3".
- [x] Créer un identifiant OAuth (type "Desktop app") : noter client_id et
      client_secret. Écran de consentement en mode test avec le compte dédié
      comme utilisateur test.
- [x] Obtenir un refresh token : https://developers.google.com/oauthplayground
      (roue dentée > "Use your own OAuth credentials"), scope
      `https://www.googleapis.com/auth/youtube.upload`, autoriser avec le
      compte dédié, échanger le code, noter le refresh_token.

## 3. Remise des clés (après-midi)

    ssh gheop.com "sudo kubectl -n radio create secret generic radio-keys \
      --from-literal=ANTHROPIC_API_KEY=sk-ant-... \
      --from-literal=ELEVENLABS_API_KEY=... \
      --from-literal=YOUTUBE_STREAM_KEY=... \
      --from-literal=TWITCH_STREAM_KEY=... \
      --from-literal=YT_CLIENT_ID=... \
      --from-literal=YT_CLIENT_SECRET=... \
      --from-literal=YT_REFRESH_TOKEN=..."

- [x] Redémarrer le stream pour qu'il prenne les clés RTMP :
      `ssh gheop.com "sudo kubectl -n radio rollout restart deployment/stream"`
- [x] Vérifier dans YouTube Studio et Twitch que le direct est EN LIGNE.

## 4. La naissance (soir)

- [x] Réveiller les crons :
      `for c in brain-ops brain-creation brain-conseil; do ssh gheop.com "sudo kubectl -n radio patch cronjob $c -p '{\"spec\":{\"suspend\":false}}'"; done`
- [x] Premier réveil supervisé (il choisit son identité, voir
      agent/prompts/conseil.md point 5) :
      `ssh gheop.com "sudo kubectl -n radio create job --from=cronjob/brain-conseil naissance"`
- [x] Suivre : `ssh gheop.com "sudo kubectl -n radio logs -f job/naissance"`
- [x] Vérifier : entrée de journal commitée (`git pull` en local), site mis à
      jour, décision d'identité dans decisions/.
- [x] À partir d'ici : ne plus rien faire. Lire le journal sur le site.

## Kill switch (à tout moment)

    for c in brain-ops brain-creation brain-conseil; do
      ssh gheop.com "sudo kubectl -n radio patch cronjob $c -p '{\"spec\":{\"suspend\":true}}'"
    done
```

- [x] **Step 2 : commit**

```bash
git add docs/jour0.md
git commit -m "docs: checklist du jour 0 (incarnation)"
```

---

### Task 15 : validation de bout en bout (pré-jour-0) et push final

**Files:** aucun

- [x] **Step 1 : test à blanc d'un réveil ops SANS clé API** (vérifie la mécanique wake/commit, pas le cerveau)

```bash
ssh gheop.com "sudo kubectl -n radio create job --from=cronjob/brain-ops test-a-blanc"
ssh gheop.com "sudo kubectl -n radio wait --for=condition=complete job/test-a-blanc --timeout=600s || sudo kubectl -n radio logs job/test-a-blanc"
```

Expected: le job se termine ; sans `ANTHROPIC_API_KEY`, `claude` échoue mais
`wake.sh` continue (`|| true`), inscrit `cout 0` dans `api_usage.csv`, publie
le site et pousse un commit `réveil ops` sur origin.

- [x] **Step 2 : vérifier le commit du job sur origin**

```bash
git pull
git log --oneline -3
tail -2 comptes/api_usage.csv
```

Expected: un commit `réveil ops` venu du cluster, une ligne `...,ops,0`.

- [x] **Step 3 : checklist finale**

```bash
ssh gheop.com "sudo kubectl -n radio get pods,cronjobs,pvc,ingress"
curl -s https://radio.gheop.com/hls/live.m3u8 | head -1
curl -s https://radio.gheop.com/journal/index.json
```

Expected: stream et web `Running`, 3 cronjobs suspendus=false uniquement après jour 0, `#EXTM3U`, un tableau JSON non vide.

- [x] **Step 4 : nettoyer le job de test et pousser**

```bash
ssh gheop.com "sudo kubectl -n radio delete job test-a-blanc bootstrap --ignore-not-found"
git push
```

- [x] **Step 5 : commit final du plan coché**

```bash
git add -A
git commit -m "chore: plan d'implémentation exécuté, prêt pour le jour 0"
git push
```

---

## Notes pour l'exécuteur

- **TDD adapté à l'infra :** chaque tâche a sa vérification exécutable
  (kubectl/curl/shellcheck) à la place d'un test unitaire ; ne jamais passer
  à la tâche suivante sans la vérification verte.
- **gheop.com est chargé (load ~11).** Les limits sont là pour ça ; ne pas
  les augmenter sans raison. Le stream recopie la vidéo : s'il consomme plus
  de ~0.2 CPU en régime, quelque chose cloche.
- **`https://api.elevenlabs.io/v1/music` :** vérifier le schéma exact du body
  dans la doc au moment de l'exécution (champ durée), adapter
  `generate-track.sh` si besoin sans changer son interface.
- **Aucun secret dans le repo.** `radio-keys` n'existe qu'au jour 0 ; tout
  est `optional: true` pour que l'infra tourne avant.
- **Ce qui appartient à l'agent après le jour 0 :** identité, boucle vidéo,
  site, playlist, ingress (sous-domaine), prompts de génération. Ne pas
  sur-polir ces parties : ce sont des placeholders volontaires.
```
