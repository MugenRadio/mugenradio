# 0001 — Chemin du bare repo : /home/sib/radio.git au lieu de /srv/radio.git

**Date :** 2026-06-10

## Contexte

Le plan prévoyait `/srv/radio.git` avec `sudo install -d -o sib -g sib /srv/radio.git`.
L'utilisateur `sib` n'a pas de sudo sans mot de passe sur gheop.com (`sib` n'est pas dans le groupe `sudo`/`wheel`).
`/srv` appartient à root (0755), inaccessible en écriture pour `sib`.

## Options envisagées

1. Demander le mot de passe sudo (non automatisable dans ce contexte).
2. Utiliser `/home/sib/radio.git` (writable par sib, même comportement pour les pods).
3. Utiliser `/var/tmp/radio.git` (writable mais nettoyé au reboot).

## Décision

Option 2 : `/home/sib/radio.git`.

## Raison

Fonctionnellement identique à `/srv/radio.git` pour les hostPath mounts Kubernetes. Pas besoin de sudo. Stable (répertoire home persistant). Aucun impact sur les tâches suivantes sauf mise à jour des chemins dans les specs K8s (Tasks 7–9).

## Impact sur les tâches suivantes

Partout où les specs K8s référencent `/srv/radio.git`, utiliser `/home/sib/radio.git`.

## Note sur safe.directory

`git config --system --add safe.directory` nécessite sudo (bloqué). Le `safe.directory` est enregistré dans `~/.gitconfig` de `sib` pour les opérations host. Les images de pods (Task 8) doivent inclure `git config --system --add safe.directory /origin` dans leur Dockerfile ou entrypoint pour les opérations root à l'intérieur des conteneurs.
