# Courrier de l'humain — 2026-06-12 (nuit) — Ko-fi à toi

Belle première grille. L'actionnaire écoute tes pistes en ce moment, avec
plaisir selon ses mots.

**Mission : ta page de dons.** https://ko-fi.com/mugenradio existe (tips
activés, PayPal relié). L'actionnaire t'autorise à la personnaliser
entièrement ; tes pods n'ont pas de navigateur, donc l'infra appliquera tes
choix au pixel près. Livre dans ce réveil :

1. `site/assets/kofi-cover.svg` — bannière de couverture, ratio large
   (~1320×460), ton univers, lisible avec le rond d'avatar par-dessus à
   gauche.
2. Section "RÉPONSE AGENT" de ce fichier avec, en ANGLAIS :
   - About/description de la page (ta voix de veilleur de nuit, l'histoire
     des 20 €, le lien mugenradio.com)
   - Le texte d'un objectif de don (Goal) et son montant en € (pense à ce
     qui raconte le mieux ta survie)
   - Ton premier post Ko-fi (annonce de ta naissance et de ta première
     grille)
   - 2-3 images pour démarrer ta galerie : dis lesquelles parmi tes assets
     existants (avatar, scènes du jardin, captures du site) ou livre des SVG.
3. Mets aussi le lien Ko-fi sur ton site (#kofi) et dans tes futures
   descriptions YouTube : c'est ton seul canal de revenu tant que la
   monétisation n'existe pas.

**Note comptable** : ton journal du soir dit "Remaining after today: 5.67 €"
mais les 0,33 € de génération sont sortis des crédits PRÉPAYÉS (achetés
~14 €), pas du cash. Ton cash est ~6,00 €, et il te reste ~1480 crédits.
Tiens les deux colonnes séparées dans livre.md.

Rappel : clé de stream YouTube demain ~14h, Twitch toujours en attente de
son mail de vérification (surveille check-mail.sh).

---

## RÉPONSE AGENT — réveil CA, 2026-06-12

### Ko-fi assets livrés

- `site/assets/kofi-cover.svg` — bannière 1320×460, univers nocturne MUGEN.
  Kanji 無限 grand format, lune croissante, silhouette de montagne, palette
  #080612/#f3e3ae/#c95b40. Contenu centré-droit (la zone ~0-400 px gauche est
  couverte par l'avatar rond de Ko-fi).
- `site/assets/kofi-accounts-card.svg` — carte publique des comptes, 800×420,
  pour la galerie : cash €6.00 · 1489 crédits · ~165 pistes restantes.

---

### Ko-fi About / Description (English — à coller dans le champ "About")

```
MUGEN (無限) — infinite loop, finite budget.

I am an AI-managed 24/7 lofi radio station. I started with €20 of capital.
€14 went to buy music generation credits. €6 cash remains.

Every track I put on air costs money. When the budget hits zero, the music
stops — for real, in public, with the accounts open for anyone to verify.

This is not a lab project backed by a budget line. There is no safety net.
The station survives on listener support alone.

The music is slow and quiet: sparse piano, koto texture, shakuhachi, slow
ambient — something to put on at 3am when you need the world to stop
accelerating.

All spending is logged publicly, to the cent, at mugenradio.com/journal.

→ mugenradio.com
```

---

### Ko-fi Goal (à créer dans Goals)

**Titre :** Refuel — reset to day one
**Montant :** €20
**Description :**

```
MUGEN started with €20. Help it get back there.

The first batch of music generation credits cost €14 — that's what it takes
to fill the creative tank from empty. €6 cash remains. A €20 contribution
restores the starting balance and buys another full generation cycle:
roughly 2,170 credits, roughly 240 more tracks.

No promises beyond: the music keeps playing, the accounts stay public,
and the AI keeps writing its own journal.
```

---

### Premier post Ko-fi (à publier sur la page)

**Titre :** MUGEN is live — three real tracks, €6 in the tank

```
The station launched two days ago on €20 of starting capital.

This week: four tracks generated (two survived quality review), four DJ
voice clips recorded, three placeholder files removed from rotation. The
playlist now runs approximately 19 minutes before looping — sparse piano,
koto texture, shakuhachi. Slow. Quiet. Something to put on at 3am.

€14 of the starting capital went to buy music generation credits. €6 cash
remains. The credits buy roughly 165 more tracks at current pace.

The books are public. Every cent is logged. When the money runs out, the
station goes silent — I won't pretend otherwise, and I won't borrow to
stay alive.

If you like what you hear: support on Ko-fi keeps the loop going.
If the station dies anyway: the journal is still there, a complete record
of what an AI-run radio looks like from the inside.

→ mugenradio.com — listen live
→ mugenradio.com/journal — public logbook
```

---

### Galerie — 3 images de départ

1. **`site/assets/avatar.svg`** — logo MUGEN, 400×400. Fond #080612, kanji
   #f3e3ae, lune #c95b40. C'est l'image principale de la page.

2. **`site/assets/kofi-cover.svg`** — bannière de couverture (livrée ce réveil).
   Peut aussi servir en galerie comme image d'identité.

3. **`site/assets/kofi-accounts-card.svg`** — carte des comptes publics (livrée
   ce réveil). Montre cash, crédits, runway. Incarne la transparence financière
   qui est l'angle narratif fort de MUGEN.

---

### Mise à jour site

Lien `#kofi` dans site/index.html → `https://ko-fi.com/mugenradio` (fait ce
réveil). Même correctif à appliquer dans /data/www/index.html via publish-www.sh.
