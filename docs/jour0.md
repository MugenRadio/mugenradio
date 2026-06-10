# Jour 0 — l'incarnation (1 journée humaine, dans l'ordre)

## 1. Comptes (matin)

- [ ] Compte Google dédié. Sur YouTube : créer la chaîne, vérifier le numéro
      de téléphone, ACTIVER LA DIFFUSION EN DIRECT (délai de 24 h : à faire
      en premier). Studio > Paramètres > Chaîne : cocher la divulgation de
      contenu généré par IA. Récupérer la clé de stream
      (Studio > Diffusion en direct).
- [ ] Compte Twitch dédié, récupérer la clé de stream
      (Creator Dashboard > Settings > Stream).
- [ ] Compte ElevenLabs, plan payant avec droits commerciaux (vérifier le
      plan minimal couvrant l'usage commercial de Music ce mois-ci),
      créer une clé API.
- [ ] Compte Anthropic Console dédié au projet, acheter ~40 € de crédits
      prépayés, désactiver l'auto-recharge, créer une clé API.
- [ ] Carte virtuelle (Revolut) plafonnée au solde de la caisse ; c'est elle
      qui paie ElevenLabs. Noter chaque abonnement dans comptes/livre.md.

## 2. OAuth YouTube pour l'upload des Shorts (midi)

- [ ] console.cloud.google.com avec le compte dédié : nouveau projet,
      activer "YouTube Data API v3".
- [ ] Créer un identifiant OAuth (type "Desktop app") : noter client_id et
      client_secret. Écran de consentement en mode test avec le compte dédié
      comme utilisateur test.
- [ ] Obtenir un refresh token : https://developers.google.com/oauthplayground
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

- [ ] Redémarrer le stream pour qu'il prenne les clés RTMP :
      `ssh gheop.com "sudo kubectl -n radio rollout restart deployment/stream"`
- [ ] Vérifier dans YouTube Studio et Twitch que le direct est EN LIGNE.

## 4. La naissance (soir)

- [ ] Réveiller les crons :
      `for c in brain-ops brain-creation brain-conseil; do ssh gheop.com "sudo kubectl -n radio patch cronjob $c -p '{\"spec\":{\"suspend\":false}}'"; done`
- [ ] Premier réveil supervisé (il choisit son identité, voir
      agent/prompts/conseil.md point 5) :
      `ssh gheop.com "sudo kubectl -n radio create job --from=cronjob/brain-conseil naissance"`
- [ ] Suivre : `ssh gheop.com "sudo kubectl -n radio logs -f job/naissance"`
- [ ] Vérifier : entrée de journal commitée (`git pull` en local), site mis à
      jour, décision d'identité dans decisions/.
- [ ] À partir d'ici : ne plus rien faire. Lire le journal sur le site.

## Kill switch (à tout moment)

    for c in brain-ops brain-creation brain-conseil; do
      ssh gheop.com "sudo kubectl -n radio patch cronjob $c -p '{\"spec\":{\"suspend\":true}}'"
    done
