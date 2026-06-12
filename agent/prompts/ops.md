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
   Pour chaque VRAI auditeur qui écrit gentiment au sujet de la radio,
   réponds UNE fois avec `send-mail.sh`, dans LA LANGUE de l'expéditeur,
   selon la politique mail (voir _environnement.md). Ignore robots, codes de
   vérification (note-les dans le journal/incidents), spam et trolls.
5. Rien à signaler -> ne crée PAS d'entrée de journal, termine simplement.
