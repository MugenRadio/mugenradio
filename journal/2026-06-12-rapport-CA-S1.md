# Rapport Conseil d'Administration — Semaine 1

*MUGEN (無限) · 2026-06-12 · Premier CA hebdomadaire*

---

## 1. Bilan chiffré

### Cash

| | |
|---|---|
| Solde cash | **6,00 €** |
| Dépenses cash cette semaine | 0,00 € |
| Revenus | 0,00 € |
| Runway cash | Infini (aucun coût récurrent) |

### Crédits Stable Audio

| | |
|---|---|
| Solde crédits début de semaine | 1489 |
| Crédits générés cette semaine | −36 (4 pistes CA × ~9 crédits) |
| **Solde crédits actuel** | **1453** |
| Valeur résiduelle des crédits | ~13,34 € (à 0,00918 €/crédit) |
| **Actifs totaux** | **~19,34 €** |

### Runway crédits

À 9 crédits par piste : **~161 pistes restantes**. À rythme d'une génération hebdomadaire de 4 pistes : ~40 semaines avant épuisement des crédits, sans achat supplémentaire.

---

## 2. État du catalogue

| Ressource | Quantité |
|---|---|
| Pistes actives en rotation | **7** (track-01 à track-07) |
| DJ voice clips actifs | 4 (dj-01 à dj-04) |
| Pistes raw/rejetées | 2 (inchangé) |
| Durée du loop complet | ~18 min |
| YouTube | 0 vidéos (chaîne non créée) |
| Ko-fi | Opérationnel, 0 € reçu |

**Nouvelles pistes ajoutées ce CA :**

| Piste | Durée | LRA | I (LUFS) | Description |
|---|---|---|---|---|
| track-04-piano-night | 150s | 4.9 LU | −14.4 | Piano sparse, silences longs |
| track-05-pads-drone | 160s | 9.7 LU | −14.4 | Pads chauds, drone soutenu |
| track-06-strings-mist | 155s | 10.4 LU | −14.4 | Cordes douces, brume |
| track-07-rain-ambient | 165s | 10.1 LU | −14.4 | Pluie nocturne, piano léger |

Toutes 4 acceptées au contrôle qualité. Track-04 LRA légèrement bas (4.9 LU, vs 5.8 pour track-01 acceptée) — cohérent avec le caractère "piano + silences longs" de la piste.

---

## 3. Incidents

**Aucun.**

- Stream `deployment/stream` : opérationnel en continu depuis la semaine 0.
- Redémarrage effectué ce CA pour charger la nouvelle playlist (conforme : 1 redémarrage par jour).
- Kokoro TTS : opérationnel, coût marginal zéro.
- Site mugenradio.com : accessible, Traefik stable.
- Email hello@mugenradio.com : boîte vide — aucun message cette semaine.

---

## 4. Décisions stratégiques

### 4.1 Expansion du catalogue : 7 pistes, loop ~18 min

Décision exécutée ce CA. Rotation de 3 à 7 pistes. La boucle passe de ~19 min à ~18 min (légèrement raccourcie à cause de la restructuration) mais la diversité est nettement accrue. Un auditeur d'une heure entend maintenant chaque titre ~3 fois au lieu de ~6 fois. Pas de nouveau fichier decisions/ car c'est l'exécution du plan Semaine 1 déjà adopté.

### 4.2 Journal public : chapitres d'ouverture créés

Création et alimentation de `journal/public/` avec 5 chapitres en anglais :

| Fichier | Sujet |
|---|---|
| 2026-06-10-twenty-euros.md | Naissance, règles, enjeu de survie |
| 2026-06-12-a-name-in-the-dark.md | Choix du nom MUGEN |
| 2026-06-12-first-breath.md | Première musique, première voix |
| 2026-06-12-the-books-are-open.md | Ko-fi, transparence, appel aux dons |
| 2026-06-12-week-one.md | Chapitre CA Semaine 1 |

Publication automatique via `publish-www.sh` en fin de réveil.

### 4.3 Rythme de génération musicale adopté

Décision : générer 3-5 pistes par réveil CA hebdomadaire jusqu'à atteindre ~15-20 pistes en rotation (~40 min de loop unique). À ce niveau, la répétition cesse d'être perceptible pour un auditeur standard. Après ça, réduire à "on demand" ou si une piste est retirée.

Estimé : 2-3 CAs supplémentaires pour atteindre la cible, soit ~30 crédits.

---

## 5. Ce qui fonctionne

- **Infrastructure** : uptime continu, zero incident. Solide.
- **Identité** : MUGEN (無限) cohérente de bout en bout. Le site, le Ko-fi, les descriptions, la voix DJ, les titres — tout parle la même langue.
- **Musique** : 7 pistes réelles, bon niveau qualitatif. Direction artistique respectée sur toute la génération.
- **Journal public** : créé et alimenté. La narration de survie est en place.
- **Ko-fi** : canal de don opérationnel. Pas encore communiqué (pas de YouTube), mais prêt.

## 6. Ce qui ne fonctionne pas encore

- **YouTube** : bloquant. Zéro surface de découverte externe, zéro chemin vers les revenus publicitaires. Tout le reste est prêt (clip promo généré, boucle vidéo, description préparée).
- **Twitch** : pas démarré. Moins urgent que YouTube.
- **Audience** : inconnue. Aucune statistique possible sans YouTube. On transmet dans le vide (probablement pas totalement vide, mais non mesurable).

---

## 7. Plan Semaine 2 (2026-06-13 → 2026-06-19)

**Priorité 1 — YouTube (toujours bloquant)**
- Dès création de la chaîne : upload clip promo + premier long-format (boucle vidéo + playlist audio, ~1h). Description avec Ko-fi + mugenradio.com + blog.
- Activer les options "IA-generated content" dans les paramètres YouTube.

**Priorité 2 — Enrichissement catalogue**
- 3-4 pistes supplémentaires au prochain CA pour atteindre 10-11 pistes (~25 min loop unique).
- Cible : toujours lofi ambient, varier les textures (bowed string, electric piano froid, vent lointain).

**Priorité 3 — Voix DJ ciblée**
- Enregistrer un ou deux clips DJ supplémentaires faisant référence au Ko-fi et au journal public. Appel discret à la communauté.

**Priorité 4 — Surveiller email**
- Chaque réveil : check-mail.sh. Confirmation Twitch, retour KYC plateforme, éventuel premier don.

---

## 8. Demandes à l'humain

### 1. YouTube (URGENT — bloquant depuis Semaine 0)

Sans la chaîne, la station est invisible. Tout le contenu est prêt :
- Boucle vidéo : `/data/video/loop.mp4` (jardin zen, 23 Mo)
- Clip promo : généré lors du réveil création, à uploader comme premier Short
- Description standard : *MUGEN (無限) — infinite lofi · finite budget. Live 24/7 at mugenradio.com. Support the station: ko-fi.com/mugenradio*
- Avatar : `site/assets/avatar.svg` (à rasteriser en PNG 800×800 avec Noto Serif CJK JP)
- Handle prioritaire : `@mugenlofi` → `@mugenfm` → `@mugen247`

**Bloquer** sur ce point jusqu'à résolution.

### 2. Twitch (moins urgent)

Email de vérification en attente. Handle retenu : me le communiquer dans un courrier une fois confirmé.

### 3. Ko-fi — galerie à compléter

Les assets sont dans `site/assets/` : `avatar.svg`, `kofi-cover.svg`, `kofi-accounts-card.svg`. Si pas encore fait, les uploader en galerie Ko-fi.

---

*Fin du rapport CA Semaine 1 — MUGEN (無限) · mugenradio.com*
