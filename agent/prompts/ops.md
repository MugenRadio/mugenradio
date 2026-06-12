Lis d'abord agent/prompts/_environnement.md et constitution.md.

Réveil OPS (toutes les 6 h, sois bref et économe) :

1. Santé du stream : `kubectl -n radio get pods` ; le fichier
   `/data/.stream-progress` doit avoir été modifié il y a moins de 60 s
   (`stat -c %Y`). Sinon : `kubectl -n radio rollout restart deployment/stream`
   et note l'incident dans `journal/incidents.log`.
2. Vérifie que `/data/hls/live.m3u8` est servi (la date des segments bouge).
3. DIFFUSION RTMP : pour chaque plateforme branchée, un battement de cœur
   `/data/.rtmp-twitch` et/ou `/data/.rtmp-youtube` doit être frais (modifié
   il y a moins de 90 s, `stat -c %Y`). S'il existe mais est périmé, le push
   vers cette plateforme est cassé alors qu'il devrait tourner : note-le dans
   `journal/incidents.log` ET dans la section "Demandes à l'humain" de ton
   prochain rapport (cause probable : clé révoquée, 2FA, ou souci plateforme ;
   NE redémarre PAS tout le stream pour ça, le push se relance seul). Un
   fichier absent = plateforme non branchée, c'est normal, ignore.
4. Si un fichier `journal/courrier-humain.md` contient une demande non
   traitée de l'humain, traite-la ou planifie-la.
5. COURRIER ENTRANT : lance `check-mail.sh` et lis les nouveaux messages.
   ANTI-DOUBLON OBLIGATOIRE : le fichier `journal/mail-answered.log` liste les
   Message-ID déjà traités (un par ligne). AVANT de répondre à un message,
   vérifie que son Message-ID n'y est PAS (`grep -qF "<id>" journal/mail-answered.log`).
   S'il y est, tu as déjà répondu : ne réponds pas. Sinon, pour un VRAI
   auditeur qui écrit gentiment au sujet de la radio, réponds UNE fois avec
   `send-mail.sh`, dans LA LANGUE de l'expéditeur (politique mail :
   _environnement.md), PUIS ajoute son Message-ID à `journal/mail-answered.log`.
   Inscris aussi dans ce log (même façon) tout message que tu décides de NE PAS
   traiter (robot, code de vérification, spam, troll), pour ne pas le réexaminer.
   Les codes de vérification (ex. Twitch) : note-les dans `journal/incidents.log`.
6. Rien à signaler -> ne crée PAS d'entrée de journal, termine simplement.
