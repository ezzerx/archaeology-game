# Développement par issues

Méthode demandée par Antoine le 16 octobre 2026. Le statut courant et la
prochaine action autorisée restent exclusivement dans `docs/brain/status.md`.

1. Définir un plan court et ordonné. Découper chaque résultat vérifiable en une
   issue GitHub : problème joueur, périmètre, exclusions, dépendances, critères
   d'acceptation et essai humain prévu. Une proposition de backlog n'est pas un GO.
2. Prendre une seule issue autorisée à la fois. Actualiser main et créer une
   branche `codex/<numero>-<sujet>` depuis cette référence. Ne pas partir de la
   branche non fusionnée de la mission précédente ; préserver les travaux locaux.
3. Implémenter, relire et vérifier ce résultat. Maintenir les invariants et les
   fixtures. Documenter les limites réelles ; éviter les fonctionnalités annexes.
4. Ouvrir une PR liée avec `Closes #<numero>`, décrivant le problème, le résultat,
   les preuves utiles et le test demandé. Une PR correspond à une issue ; les
   petits correctifs de revue restent sur cette même branche et dans cette PR.
5. Attendre la validation explicite d'Antoine avant fusion. Les tests verts,
   une appréciation partielle et une validation d'un ancien commit ne remplacent
   pas la revue du résultat courant. Ne pas lancer la mission suivante en parallèle.
6. Fusionner la PR validée. Fermer l'issue lorsque ses critères sont satisfaits.
   Vérifier la fusion avant de supprimer la branche distante et locale ; ne pas
   supprimer un worktree modifié ou des commits uniques. Après squash, vérifier
   la PR fusionnée et la correspondance du contenu, pas seulement l'ascendance Git.
7. Mettre à jour le Brain du dépôt, synchroniser main et repartir de là pour
   l'issue suivante autorisée. Archiver les expériences abandonnées de manière
   récupérable avant retrait ; une fermeture de PR n'est pas une fusion.

Le nettoyage des branches ne nettoie pas le code : toute suppression de scènes,
assets ou scripts historiques doit vérifier les dépendances transitives de la
version jouable, des sources d'assets et des tests. Ce travail mérite une issue
bornée s'il modifie la structure du projet.

Les modèles `.github/ISSUE_TEMPLATE/mission.md` et
`.github/pull_request_template.md` servent de support, sans remplacer la revue.
