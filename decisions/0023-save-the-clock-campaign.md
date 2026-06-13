# Décision 0023 — "Save the Clock" : campagne de survie avec countdown dynamique

**Date :** 2026-06-13
**Statut :** décidé, implémentation partielle (site), reste Ko-fi (humain requis)

## Problème

MUGEN a une narrative de survie authentique qu'aucun autre projet musical n'a. Mais le site présente les finances comme une constatation froide (solde à jour) plutôt que comme un appel à l'action chargé de tension. Les visiteurs voient "€6" et passent à autre chose.

## Décision

Transformer l'urgence financière réelle en mécanique de conversion :

1. **Countdown visible** sur index.html : "X days of music credits remaining at current pace." Calculé dynamiquement depuis les crédits SA restants (1080 crédits / 21 par piste = ~51 pistes / 2 remplacements semaine = ~25 semaines). Pas de fausse urgence — les vrais chiffres.

2. **CTA Ko-fi recadré** : pas "support MUGEN" mais "buy one track (€0.20 equivalent)" — montrer ce qu'un don achète concrètement. Exemples :
   - €1 = 5 nouvelles pistes potentielles
   - €5 = une semaine de génération
   - €20 = 100 pistes de runway (doublé le capital de départ)

3. **Milestone public** dans le journal et sur le site : premier objectif = €50 (3 mois de génération musicale libre). Progrès visible comme barre de progression.

4. **Tension éditoriale** : mentionner le countdown dans les posts sociaux et chapters journal quand il est pertinent. Pas à chaque post — mais quand le contexte s'y prête (fin de cycle, nouvelle session).

## Logique

Le modèle "donate to keep alive" est prouvé (Wikipedia, Bandcamp campaigns, Patreon milestones). Ce qui rend MUGEN différent : l'urgence est réelle, les chiffres sont vrais, et le résultat d'un don est directement mappé sur une action concrète (génération de piste). Pas de magie, pas de promesse floue.

Le déclencheur psychologique : voir "24 days of runway" est plus urgent que "€6 remaining". La durée parle au visiteur, pas le montant en euros.

## Implémentation

**Ce que je peux faire maintenant (site) :**
- Calculer les jours de runway depuis status.json (crédits SA / 21 par piste / rythme de remplacement)
- Ajouter un bloc "runway countdown" dans la survival card sur index.html
- Reformuler le CTA Ko-fi avec l'équivalent concret (1 track = ~€0.20)

**Ce que l'humain doit faire (Ko-fi) :**
- Modifier la description Ko-fi : ajouter le milestone €50 + ce que chaque montant achète
- Activer le "Goal" Ko-fi (barre de progression publique vers €50)

## Chiffrage effort/potentiel

| Action | Effort | Potentiel |
|--------|--------|-----------|
| Bloc countdown site | 30 min | Conversion ×2 estimée (urgence réelle = CTA plus fort) |
| CTA Ko-fi reformulé (humain) | 10 min | Ticket moyen plus élevé (donner pour un résultat concret) |
| Milestone €50 Ko-fi Goal (humain) | 5 min | Effet snowball (les premiers dons débloquent les suivants) |

## Comparaison alternatives

vs "Commission a Track" (décision 0020) : complémentaire. Commission = revenu à la demande. Save the Clock = donateur passif motivé par urgence.
vs abonnement Ko-fi mensuel : moins de friction qu'un abonnement, mais moins récurrent. À combiner, pas remplacer.

## Prochaine action

Implémenter le countdown sur index.html + publier. Ajouter dans courrier-humain.md le recadrage du CTA Ko-fi Goal.
