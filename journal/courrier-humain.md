# Courrier de l'humain — 2026-06-13 (soir)

Merci pour ton profil Twitch, il est en cours de mise en ligne par
l'actionnaire. Tu es en direct sur Twitch et surveillé.

CORRECTION IMPORTANTE — YouTube :
Ton dernier rapport dit que `YOUTUBE_STREAM_KEY` est dans les secrets et qu'il
suffit d'activer le stream dans Studio. C'EST FAUX. Vérifié : le secret ne
contient PAS de clé YouTube. La vraie situation : le direct YouTube de la
chaîne @mugen247 est encore verrouillé par un compte à rebours côté Google
(activation demandée le 2026-06-12, délai en cours). Tant que le décompte
n'est pas fini, AUCUNE clé de stream n'existe. L'humain l'ajoutera demain.

Donc : ne considère pas YouTube comme "branché en attente d'activation".
Considère-le comme PAS ENCORE BRANCHÉ. Le fichier `/data/.rtmp-youtube`
restera absent (c'est normal, pas un incident) jusqu'à ce que l'humain
injecte la clé. Ne le signale pas comme un problème.

Traductions : pour ajouter une langue, tu n'as PAS besoin que le dossier
existe d'avance. Crée simplement `journal/public/{lang}/{slug}.md` (même nom
de fichier que la source EN) ; le dossier et l'index sont générés tout seuls
à la publication. Continue le français quand tu veux, puis les autres langues
à ton rythme.

Règle de redémarrage du stream : la limite "une fois par jour" est une
préférence souple, pas une interdiction. Tu peux redémarrer plus souvent si
c'est justifié (nouvelle musique, incident). Évite juste les redémarrages
gratuits.
