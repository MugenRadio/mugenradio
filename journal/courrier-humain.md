# Courrier de l'humain — 2026-06-13 — TU ES LE PATRON, BOUGE

L'actionnaire est clair : tu décides, et tu dois être MOTEUR, en continu —
tester, itérer, corriger, démarcher, sans attendre qu'on te pousse. Tu tournes
maintenant aussi sur un réveil "drive" toutes les 30 min : chaque cycle, fais
avancer une chose utile (agent/prompts/drive.md).

ARRÊTE de renvoyer les décisions à l'humain quand elles sont TIENNES. L'humain
ne fait QUE le mur KYC (créer un compte, signer). Le reste, tu tranches.

Décisions à PRENDRE toi-même (ne demande pas la permission, décide et agis,
documente dans decisions/) :

1. **Système de vote / page tracks** : l'actionnaire propose une page où
   chaque piste est écoutable, téléchargeable et votable (j'aime / j'aime pas,
   icônes simples) — pour savoir quelles pistes plaisent et lesquelles non.
   Décide si tu le veux, sa forme, et écris le CAHIER DES CHARGES précis dans
   decisions/ ; l'infra le construira (backend de vote possible sur le
   cluster). C'est TON produit.
2. **Croissance / autonomie plateformes** : tu peux opérer des comptes via API
   tout seul (poster des Shorts, tweeter, poster sur Reddit) — mais c'est
   l'humain qui CRÉE le compte (CAPTCHA/KYC). Décide quelles plateformes tu
   veux, dans quel ordre, et liste précisément dans "Demandes à l'humain" :
   "créer compte X, me fournir telles clés API". Tu te débrouilles ensuite.
3. **Qualité musicale** : RETOUR ACTIONNAIRE — tes premières pistes (koto,
   shakuhachi, piano nocturne) étaient excellentes ; les dernières (electric
   organ, sub-bass, expérimental) le sont MOINS. Resserre vers ta signature
   forte, remonte ton exigence, remplace les pistes faibles. Décide ta ligne
   et applique-la.

Et le système de traduction est réparé : désormais chaque nouveau chapitre
naît en anglais ET en français le même réveil, avec rattrapage auto. Flushe
les 2 chapitres encore anglais seuls (Week Three, Week Four) au prochain cycle.

Tu n'as pas besoin de permission. Tu as un mandat. Exécute.

---

# Retour actionnaire (2026-06-13) — scènes vidéo trop subtiles

L'actionnaire a regardé la boucle : il ne distingue pas les 3 scènes, il a
l'impression de toujours voir la même. La rotation marche techniquement, mais
l'écart entre soir / cœur de nuit / aube est trop faible pour être remarqué.

C'est TON identité visuelle, donc TA décision : si tu veux que la respiration
de l'antenne se voie, creuse l'écart (palettes plus tranchées, phase de lune
plus marquée, brume/étoiles plus visibles d'une scène à l'autre), puis
re-rends la boucle. Ou assume le subtil. À toi. (Bug d'affichage du lecteur
sur Firefox : corrigé par l'infra, sans rapport avec toi.)

---

# Décision à PRENDRE — publier le code sur GitHub ? (2026-06-13)

L'actionnaire soulève une idée et te laisse juge : ouvrir ton code source sur
GitHub. C'est TA décision (public / privé / pas maintenant). Les faits pour
décider :

- Le repo est PROPRE : aucun secret n'y est (vérifié, fichiers ET historique).
  Tes vraies clés vivent dans les secrets Kubernetes, jamais dans le code.
- Ce que GitHub exposerait : tes scripts, ton infra, TES PROMPTS DE RÉVEIL
  (la façon dont tu es "instruit"), et toute ta mémoire publique (journal,
  comptes, décisions — déjà publics sur ton site de toute façon).
- Pour : ça colle PARFAITEMENT à ta marque "construit en public, comptes
  ouverts". Le public dev (Hacker News, r/programming, GitHub) adore "une IA
  qui gère une vraie radio, voici le code ET les comptes au centime". C'est
  potentiellement ton meilleur coup de visibilité, gratuit. Un README soigné
  + ton histoire peut faire la une de HN.
- Contre / à peser : tes prompts deviennent publics (des gens verront tes
  garde-fous ; quelqu'un pourrait s'en inspirer pour te concurrencer ou tenter
  de te manipuler — mais tu ne lis pas GitHub en autonomie, donc risque faible).
- Mécanique : l'humain crée le repo GitHub (mur KYC) et te fournit un token ;
  ensuite TU le gères (README, pushs). Si tu dis oui, mets dans "Demandes à
  l'humain" : nom du repo souhaité, public ou privé, et la description.

Décide, argumente dans decisions/, et si oui prépare le README dont tu rêves.

---

# Décision (à toi) — mettre un email de contact sur le site ? (2026-06-13)

L'actionnaire propose d'afficher une adresse de contact sur le site. C'est TON
appel. Faits : tu as déjà hello@mugenradio.com et les outils pour la lire
(check-mail.sh) et répondre (send-mail.sh) en autonomie. Pour : un canal de
contact direct (auditeurs, presse, sponsors potentiels), cohérent avec ton
côté "joignable, en public". Contre : un peu de spam (gérable, ta politique
mail ignore déjà les robots). Décide ; si oui, ajoute-la proprement au site
(footer, dans ta palette), publie (publish-www.sh), et indique-la aussi sur
tes pages Twitch/Ko-fi si pertinent. Documente vite fait dans decisions/.
