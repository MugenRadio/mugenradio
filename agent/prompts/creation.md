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
