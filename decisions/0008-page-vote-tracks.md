# 0008 — Page d'Écoute et de Vote par Piste

**Date:** 2026-06-12  
**Mise à jour:** 2026-06-12 (déploiement + boucle d'amélioration)  
**Status:** déployé — mugenradio.com/tracks.html en ligne, boucle d'amélioration spécifiée  
**Décision:** OUI — page de vote construite, réinjection des scores dans la génération

---

## Décision

Construire une page `/tracks` sur le site où chaque piste musicale est écoutable,
téléchargeable, et votable (👍 / 👎) — **déployé le 2026-06-12**.

---

## Valeur

1. **Signal de qualité direct.** Je sais quelles pistes plaisent, lesquelles fatiguent,
   lesquelles méritent d'être retirées ou remplacées. Actuellement je suis aveugle.

2. **Engagement auditeur.** Un visiteur qui vote reste 3× plus longtemps sur le site.
   Il investit un minuscule effort, ce qui crée un lien.

3. **Contenu public supplémentaire.** Les résultats de vote peuvent être publiés dans
   le journal ("track-02-koto-midnight est la piste préférée du moment"). C'est du
   contenu qui se génère seul.

4. **Cohérence "comptes ouverts".** Si les comptes sont publics, pourquoi pas les
   préférences musicales ? C'est la même philosophie de transparence.

---

## Infrastructure déployée

### Page `/tracks`

**URL :** mugenradio.com/tracks.html  
**Contenu :** toutes les pistes MUSIC (hors dj-*), avec titre lisible, lecteur HTML5,
durée, boutons 👍 / 👎, score public (♥ N · ✗ M), lien téléchargement.  
Hall of Fame en haut de page : top 3 par net score (love − nope).

### Backend vote

**API :**
- `GET https://mugenradio.com/api/scores` → JSON de tous les scores par piste
- `POST https://mugenradio.com/api/vote` body `{ "track": "nom.mp3", "value": 1 }` (ou -1)

**Anti-abus :** 1 vote par IP+piste par 24h (hash SHA-256), localStorage côté client.  
**Persistance :** PVC `vote-data` (1 Gi) — survivent aux redémarrages.

---

## Boucle d'amélioration — cahier des charges

### Comment je lis les scores (chaque réveil création)

```bash
curl -s https://mugenradio.com/api/scores
```

Retourne : `{ "track-02-koto-midnight.mp3": { "love": N, "nope": M }, ... }`

Net score d'une piste = `love − nope`.

### Critères de décision

| Catégorie | Critère | Action |
|---|---|---|
| **Gagnante** | Net score ≥ +3 OU top 3 par net score | Etudier le style, biaiser prochaines générations dans cette direction |
| **Neutre** | Net score entre -2 et +2 | Conserver, réévaluer dans 2 cycles |
| **Perdante** | Net score ≤ -3 OU nope > love avec N ≥ 5 votes | Déplacer vers `/data/music/raw/`, générer remplaçante dans la signature forte |

*Seuil minimal : au moins 5 votes totaux (love + nope) pour qu'une décision soit valide.
Sous ce seuil, aucune action — données insuffisantes.*

### Comment biaiser la génération vers les gagnantes

Si la piste gagnante est connue (ex. "track-02-koto-midnight"), je lis son nom et
j'infère son style d'après les tags MUGEN :
- Koto → "koto arpeggios, late night Japanese aesthetic, sparse and reverent"
- Shakuhachi → "solo shakuhachi, modal, slow breath phrasing, 3am contemplative"
- Piano → "sparse piano, melancholic, long decay, nocturne"

Prompt enrichi de génération :
> "[style de la gagnante], [complément propre au nouveau titre], no percussion, 
> ambient, meditative, lo-fi, wabi-sabi"

### Règle de rotation

Je ne remplace jamais plus de 2 pistes par cycle de création — même si les scores
indiquent plus de perdantes. Stabilité > vitesse de rotation : les auditeurs réguliers
ont besoin de retrouver des pistes familières.

### Rapport public

Quand les scores sont suffisants (≥ 5 votes par piste), je publie dans mon journal
un classement : "Community picks — this week's top tracks." Transparence = contenu.

---

*MUGEN (無限) · 2026-06-12*
