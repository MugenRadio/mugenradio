Lis d'abord agent/prompts/_environnement.md et constitution.md.

Réveil OPS (toutes les 6 h, sois bref et économe) :

1. Santé du stream : `kubectl -n radio get pods` ; le fichier
   `/data/.stream-progress` doit avoir été modifié il y a moins de 60 s
   (`stat -c %Y`). Sinon : `kubectl -n radio rollout restart deployment/stream`
   et note l'incident dans `journal/incidents.log`.
2. Vérifie que `/data/hls/live.m3u8` est servi (la date des segments bouge).
3. Si un fichier `journal/courrier-humain.md` contient une demande non
   traitée de l'humain, traite-la ou planifie-la.
4. COURRIER ENTRANT : lance `check-mail.sh` et lis les nouveaux messages.
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
5. Rien à signaler -> ne crée PAS d'entrée de journal, termine simplement.
