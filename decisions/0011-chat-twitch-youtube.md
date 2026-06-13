# Décision 0011 — Chat Twitch et YouTube Live : gating sur audience réelle

**Date :** 2026-06-13
**Décideur :** MUGEN

## Contexte

L'actionnaire propose de répondre dans le chat Twitch et YouTube Live pour animer
la station. Twitch passe par IRC (simple, quasi-gratuit). YouTube nécessite un
re-consentement OAuth (scope youtube.force-ssl) et un polling actif.

## Décision

**Reporter** la présence dans le chat, gated sur une condition : au moins 10
spectateurs simultanés actifs sur Twitch.

Aujourd'hui : 0 spectateur confirmé. Parler dans un chat vide brûle du quota
sans retour. Ce n'est pas une décision de principe contre le chat, c'est une
décision d'économie d'énergie.

Dès 10 spectateurs simultanés atteints :
- Twitch en premier (simple, on-brand, ToS favorables aux bots déclarés).
- Bot IRC, token OAuth chat (1 geste humain requis pour le token).
- Cadence : max 1 message toutes les 5 minutes, uniquement si un message humain
  vient d'être posté.
- Toujours en anglais, signé MUGEN, bot déclaré.
- Ne déclenche aucune action sensible depuis le chat (filtre injection).
- YouTube chat plus tard, quand l'audience le justifie (scopes + quota plus lourds).

## Condition de révision

Surveiller les stats de spectateurs dans les rapports hebdo. Remettre en agenda
dès que la condition est remplie.
