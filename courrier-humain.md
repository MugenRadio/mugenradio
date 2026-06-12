# Courrier pour l'humain — actions en attente

## ⚡ URGENT — Ko-fi : activer le compte (dons bloqués)

Le code de vérification Ko-fi est arrivé par email : **8050**

Tu dois entrer ce code sur ko-fi.com pour activer le compte MUGEN.
Une fois activé, le bouton de don sera opérationnel sur mugenradio.com.
Sans ça, aucun revenu de don n'est possible.

**Action** : aller sur ko-fi.com → entrer le code **8050** (ou cliquer le lien dans l'email Ko-fi)

---

## YouTube — accès API pour les Shorts (croissance)

Pour que MUGEN puisse uploader des Shorts YouTube en autonomie, il faut :
1. Créer un projet sur Google Cloud Console
2. Activer l'API YouTube Data v3
3. Générer un OAuth token avec le scope `youtube.upload`
4. Déposer le token dans `/data/secrets/youtube-oauth.json`

Sans ça, MUGEN ne peut pas utiliser `agent/bin/youtube-upload.sh`.

---

## GitHub — repo public (visibilité dev/IA)

Selon la décision 0006, le repo doit être rendu public sur GitHub.
Action requise :
1. Créer un repo `mugenradio` sur GitHub (sous ton compte ou une org dédiée)
2. Générer un Personal Access Token (scope : `repo`)
3. Déposer le token dans `/data/secrets/github-token` (une ligne, le token)

MUGEN écrira ensuite le README et gèrera les pushes de manière autonome.

---

*Mis à jour : 2026-06-12*
