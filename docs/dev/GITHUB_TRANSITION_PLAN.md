# Transition vers des missions bornées

Plan du 16 octobre 2026. Pour la gate courante, consulter `docs/brain/status.md`.

## Ordre des issues

| Ordre | Résultat | Issue |
| --- | --- | --- |
| 1 | Consolider la version jouable et la méthode de travail | [#25](https://github.com/ezzerx/archaeology-game/issues/25) |
| 2 | Isoler le code actif et retirer les expériences inutiles | [#26](https://github.com/ezzerx/archaeology-game/issues/26) |
| 3 | Représenter les arrivages dans l'atelier | [#27](https://github.com/ezzerx/archaeology-game/issues/27) |
| 4 | Présenter la collection comme un objet du muséum | [#28](https://github.com/ezzerx/archaeology-game/issues/28) |

#24 est l'exception de transition : elle rassemble déjà la chaîne historique.
La découper artificiellement après coup multiplierait les versions à revalider.
La recommandation est de la juger comme base jouable avec interfaces provisoires,
puis de repartir de main. L'alternative, si cette base n'est pas acceptable,
est de corriger la consolidation avant fusion, sans empiler de nouvelle branche.

Les issues artistiques proposent une desserte de caisses et un registre
photographique (ou un tiroir). Antoine doit encore choisir leur composition.
L'objectif est la continuité avec l'atelier chaud et matériel, l'accès rapide à
la fouille et le plaisir de revoir sa préparation, sans grands panneaux de menu.

## Inventaire contrôlé avant nettoyage

- Main : `ff3ffd7`. Candidate : `09593a3`, 36 commits d'avance, aucun commit
  exclusif à main ; PR #24 seule PR ouverte, en draft. Aucun ticket ouvert avant
  la création de ce plan.
- Neuf branches distantes `prototype/*` étaient des ancêtres de main : P0, P1,
  P2, P3, P4, P4V, P4V2, P5, P6A. Elles ont été supprimées.
- Dix branches locales de ces générations (dont deux variantes suffixées m)
  ont été supprimées. `prototype/p6a-visual-spike` reste attachée au checkout
  principal modifié : conservée, même si sa branche distante a été retirée.
- P6A39–49 sont contenues dans la candidate, pas dans main : retirer leurs
  branches après fusion vérifiée de #24. Leurs PR sont déjà fermées.
- P6A38 n'est contenue ni dans main ni dans la candidate : trois commits uniques,
  tête `14acef48402314c8775ef4a8242c8d2888b2a26c`. Préserver une référence d'archive
  distante vérifiée avant suppression. Ne pas la déclarer fusionnée.
- P6A50 reste la branche de revue. Les cinq worktrees P4 en HEAD détachée et le
  checkout principal sont préservés ; aucune suppression de dossiers utilisateur.
- Réglage GitHub `delete_branch_on_merge=true` vérifié. Ce réglage n'autorise
  aucune fusion automatique et ne nettoie pas les branches locales.

## Risque à traiter dans #26

La scène P6A50 hérite de P6A49 ; `specimen_block.gd` hérite de
`final_block.gd`, qui hérite de P6A41 `rough_block.gd`. Les ressources et les
fixtures réutilisent aussi des générations antérieures. Les numéros de dossiers
ne permettent donc pas de décider ce qui est supprimable. Auditer le graphe
complet avant tout déplacement ou retrait, puis vérifier imports, régressions
et parcours natifs. Préserver l'ammonite, le B–17, les poches et les sauvegardes.

Cette passe de gouvernance ne modifie ni les scènes ni le gameplay. Vérification :
ascendance Git, état distant, paramètres du dépôt, liens issues/PR, diff documentaire.
