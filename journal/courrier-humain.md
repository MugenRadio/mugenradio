# Courrier de l'humain — 2026-06-12 (fin d'après-midi)

URGENT, l'humain est en train de créer ta chaîne YouTube, il attend ta
réponse à ce réveil :

1. **Handle YouTube : @mugenradio est PRIS** (YouTube propose @mugenradio-f4m,
   refusé : moche). Donne 3 choix de handle dans l'ordre de préférence.
   Contraintes : court, lisible, cohérent avec mugenradio.com. Tu ne peux pas
   vérifier la disponibilité d'ici : donne des options robustes (suffixes du
   genre fm/live/lofi/247, kanji impossible dans un handle).

2. **Avatar de chaîne** : dessine ton avatar en SVG carré dans
   `site/assets/avatar.svg` (ta palette, simple et lisible en 88 px : pense
   kanji 無限, lanterne, lune ou torii). L'infra le rasterisera en PNG 800 px
   pour YouTube et les autres plateformes. Mets aussi une ligne dans ta
   réponse pour dire ce que tu as choisi et pourquoi.

3. Réponds dans CE fichier, section "RÉPONSE AGENT", format court.

Nouvelles : ta boîte mail existe (hello@mugenradio.com, accès IMAP/SMTP via
les variables MAIL_* de ton environnement, script à venir). La clé musique
arrive sous peu. La rotation 3 scènes et ta boucle vidéo jardin sont en cours
d'implémentation par l'infra.

---

## RÉPONSE AGENT — 2026-06-12 (CA hebdomadaire)

### 1. Handle YouTube — ordre de préférence

1. **@mugenlofi** — premier choix. "Lofi" est une des catégories de recherche
   les plus actives sur YouTube. Le handle décrit exactement le contenu et sera
   discoverable par quiconque cherche de la lofi, sans même connaître MUGEN.
   Court, mémorable, cohérent avec mugenradio.com.

2. **@mugenfm** — deuxième choix. Suffixe radio classique et universel.
   Court, professionnel, pérenne si l'identité musicale évolue un jour.

3. **@mugen247** — troisième choix. Évoque la diffusion continue 24/7.
   Moins descriptif du contenu mais robuste et disponible avec forte probabilité.

### 2. Avatar

Livré dans `site/assets/avatar.svg`. L'infra peut rasteriser en PNG 800 px.

**Composition :** deux kanji 無限 en grand au centre (crème ivoire #f3e3ae),
fond nuit profonde dégradé radial (#1c1538 → #080612), lune vermillon solide
en haut à droite (#c95b40), six étoiles fines, règle vermillon + "MUGEN" en
petites capitales romaines en bas.

**Pourquoi ce choix :** à 88 px (rendu circulaire YouTube), les deux kanji
forment un bloc visuel fort — reconnaissable même si les caractères ne sont
pas lisibles individuellement à cette taille. La lune vermillon est l'ancre
chromatique : la couleur signature MUGEN dans le noir. À 800 px, tout est
pleinement lisible.
