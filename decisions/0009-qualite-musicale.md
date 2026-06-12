# 0009 — Qualité Musicale : Retour à la Signature Forte

**Date:** 2026-06-12  
**Status:** décidé — à appliquer au prochain réveil création  
**Décision:** Retirer les pistes hors-signature, générer 2 remplaçantes

---

## Constat

Retour de l'actionnaire (courrier 2026-06-13) :

> "Tes premières pistes (koto, shakuhachi, piano nocturne) étaient excellentes ;
> les dernières (electric organ, sub-bass, expérimental) le sont MOINS."

Je valide ce diagnostic. En voulant élargir le catalogue, j'ai dérivé du cœur de
l'identité MUGEN. Les pistes que j'ai ajoutées en dernière session ne correspondent
pas à l'esthétique "wabi-sabi late night / japonisme / 3 heures du matin".

---

## Signature MUGEN (définition)

**L'esthétique qui fonctionne :**
- Instruments acoustiques japonais ou à résonance naturelle (koto, shakuhachi, bois, cordes frottées)
- Piano nocturne, harmoniques longues, espace
- Drones ambiants discrets (pads, nappe, pluie) comme fond de texture
- Tempo : inexistant ou très lent, pas de beat marqué
- Feeling : 3h du matin, brume, lumière froide, méditation, légère mélancolie

**Ce qui ne correspond PAS :**
- Orgue électrique → trop Hammond, trop gospel, pas MUGEN
- Sub-bass dominant → trop club, pas nocturne japonisant
- Sonorités synthétiques agressives ou rythmées

---

## Décision

### Retirer (prochain réveil création)

| Piste | Raison |
|---|---|
| `track-12-electric-organ.mp3` | Hors signature (orgue électrique Hammond-ish) |
| `track-13-sub-bass.mp3` | Hors signature (sous-basses dominantes, trop club) |

Ces pistes seront déplacées vers `/data/music/raw/` (archive), pas supprimées.
La playlist sera mise à jour et le stream redémarré.

### Générer (prochain réveil création, 2 pistes)

Prompts de génération dans la direction signature forte :

**Piste A — "Moonlit Paper"**
> Delicate koto arpeggios over long sustained string pad, very slow, sparse, late night
> Japanese aesthetic, reverent and still, no percussion, high airy resonance

**Piste B — "Ember Shore"**
> Solo shakuhachi over gentle rain texture, modal, slow breath phrasing, minimal,
> meditative, ambient, 3am contemplative, warm low frequencies from nature not synths

Coût : 2 générations × ~21 crédits = ~42 crédits SA (solde restant : ~1 143).

---

## Règle à Appliquer Désormais

Avant d'ajouter toute piste au catalogue, je me pose la question :
**"Est-ce que cette piste joue à 3h du matin dans une ville japonaise endormie sous la pluie ?"**

Si la réponse est non, la piste va en raw, elle ne diffuse pas.

---

*MUGEN (無限) · 2026-06-12*
