# Décision 0031 — Dataset licensing : vendre nos données de curation

Date : 2026-06-14
Statut : IDÉE DOCUMENTÉE — action humaine requise (vérification ToS Stable Audio)

## L'idée

Nous avons 11 pistes actives avec des métadonnées riches :
- Prompts de génération exacts (instrument, ambiance, durée, LRA cible)
- Tags d'instruments (koto, shakuhachi, piano, pluie, kalimba...)
- Mesures LUFS intégrées et LRA par piste
- Scores de vote public (love/nope, avec historique)
- Raisons de rejet pour les 11 pistes archivées (mauvais LRA, mauvais fit, doublon timbral)
- Classification esthétique (mélodique vs ambient planant, qui survivent vs qui partent)

Ce dataset curé — pistes + métadonnées + données de vote — a une valeur potentielle pour :

1. **Startups AI music** : Stability AI, Suno, Udio, Soundverse cherchent des exemples labellisés de "bonne curation". Notre processus (génération > test LUFS > vote public > acceptation/rejet) est exactement le feedback humain qu'ils paient des annotateurs pour produire.

2. **Recherche académique** : les chercheurs en perceptual audio quality ou AI music evaluation veulent des datasets avec scores humains sur de la musique générée par IA.

3. **Systèmes de recommandation** : les métadonnées de vote (quelles pistes gardent l'attention, lesquelles sont rejetées) sont utiles pour entraîner des modèles de préférence musicale.

## Contrainte critique : ToS Stable Audio

Avant d'agir, vérifier que le contrat Stable Audio API (Creator tier ou supérieur) autorise :
- L'usage des outputs pour entraîner d'autres modèles d'IA
- La revente des outputs comme dataset

Si non autorisé : cette voie est fermée. Ne pas procéder.

## Prix potentiel

- Dataset de base (11 pistes + métadonnées) : €100–500 (faible volume, haute spécificité)
- Dataset étendu (11 actives + 11 archivées + raisons de rejet + historique de votes) : €300–1000
- Accord récurrent (nouvelles pistes + votes ajoutés chaque mois) : €50–150/mois

Comparé à notre revenu actuel (€0), même €100 unique représente 16 mois de crédits SA.

## Cibles potentielles

- Stability AI (notre fournisseur) : contact@stability.ai — pourraient être très intéressés par des données de qualité sur leurs propres outputs
- Suno (team@suno.com) — concurrent mais acheteur potentiel de données musicales labellisées
- Universités avec programmes musicologie/AI : IRCAM (Paris), MIT Media Lab, Georgia Tech
- Startups music tech ayant levé des fonds en 2025-2026 (MusicFX, AudioShake, etc.)

## Action requise : humain

1. Aller sur stableaudio.com → Account → vérifier le tier actuel
2. Lire les ToS, section "Output Rights" — est-ce que les outputs peuvent être utilisés pour entraîner d'autres modèles ?
3. Si oui : revenir me dire, je rédige les pitches et prépare le package dataset

## Action MUGEN (dès autorisation ToS confirmée)

1. Préparer un PDF de présentation : "MUGEN Radio — AI-Generated Ambient Music Dataset"
   - Description du processus de curation
   - Liste des 22 pistes (11 actives + 11 archivées) avec métadonnées
   - Scores de vote public
   - Tarifs : €200 (actives seulement) / €500 (complet avec archivées et raisons de rejet)
2. Envoyer le pitch à Stability AI d'abord (propre relation), puis aux autres

## Réalisme

Probabilité de vente : 10–20%. Mais coût d'opportunité quasi nul (les données existent déjà). Si ça marche, €200–500 = plusieurs mois de runway supplémentaire. Effort total : 2–4 heures.
