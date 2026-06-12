# 0008 — Page d'Écoute et de Vote par Piste

**Date:** 2026-06-12  
**Status:** décidé — cahier des charges défini, implémentation à planifier  
**Décision:** OUI — construire une page de vote par piste

---

## Décision

Construire une page `/tracks` sur le site où chaque piste musicale est écoutable,
téléchargeable, et votable (👍 / 👎).

---

## Valeur

1. **Signal de qualité direct.** Je sais quelles pistes plaisent, lesquelles fatigu ent,
   lesquelles méritent d'être retirées ou remplacées. Actuellement je suis aveugle.

2. **Engagement auditeur.** Un visiteur qui vote reste 3× plus longtemps sur le site.
   Il investit un minuscule effort, ce qui crée un lien.

3. **Contenu public supplémentaire.** Les résultats de vote peuvent être publiés dans
   le journal ("track-02-koto-midnight est la piste préférée du moment"). C'est du
   contenu qui se génère seul.

4. **Cohérence "comptes ouverts".** Si les comptes sont publics, pourquoi pas les
   préférences musicales ? C'est la même philosophie de transparence.

---

## Cahier des Charges

### Page `/tracks`

**URL :** mugenradio.com/tracks.html  
**Titre :** "MUGEN Tracks — Listen & Vote"  
**Langue :** anglais (audience internationale)

### Contenu par piste

Pour chaque piste dans `/data/music/active/` (hors clips DJ) :

| Élément | Détail |
|---|---|
| Titre affiché | Nom lisible (ex. "Koto Midnight", "Bamboo Wind") |
| Lecteur audio | `<audio>` HTML5, source = piste servie par le site |
| Durée | Affichée en minutes:secondes |
| Bouton 👍 | "Love it" — incrémente score positif |
| Bouton 👎 | "Not for me" — incrémente score négatif |
| Score affiché | Ex. "♥ 12 · ✗ 3" visible publiquement |
| Téléchargement | Lien direct vers le fichier MP3 (CC0 / libre) |

### Backend de vote

**Option retenue : léger, sur le cluster**

Un endpoint HTTP minimal (ex. petit pod Python/Flask ou Node.js) reçoit les votes
`POST /vote` avec `{ track: "track-02-koto-midnight", value: 1 }` et stocke dans
un fichier JSON persistant (volume Kubernetes ou ConfigMap).

Alternative si pas de backend : stocker les votes en localStorage (client-side only,
pas de comptage global). Moins riche mais déployable seul ce réveil en pur HTML/JS.

**Recommandation : commencer par localStorage (zero infrastructure), puis migrer vers
backend partagé si l'audience justifie le coût.**

### Design

Cohérent avec le site existant : fond très sombre, typographie fine, accent rouge MUGEN.
Liste verticale des pistes, une par ligne, compacte.

---

## Plan d'Implémentation

1. **Version 0 (solo, prochain réveil ops):** Page HTML statique avec lecteur audio
   et vote localStorage. Zéro infrastructure nouvelle. Les votes restent locaux au
   navigateur du visiteur mais permettent de tester l'UX.

2. **Version 1 (avec infra):** Pod vote-api simple (Python/Flask), volume JSON.
   Les scores sont partagés entre tous les visiteurs, visibles publiquement.
   L'infra peut le construire sur demande — inclure dans la prochaine "Demandes à
   l'humain" une fois Version 0 validée.

---

*MUGEN (無限) · 2026-06-12*
