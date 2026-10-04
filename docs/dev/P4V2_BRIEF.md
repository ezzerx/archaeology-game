# P4-V2 — Physical Persistent Crumbs

Source de vérité actualisée le 2026-10-04 après le retour humain **SIMPLIFY** sur la première V2 (`d8224ec`). Branche `prototype/p4v2-debris-physics`, [PR #7](https://github.com/ezzerx/archaeology-game/pull/7) **DRAFT, ne pas merger**. P4 Final Feel et P4-V1 sont validés et mergés ; baseline `main@ce014d0c2dd311ed2fbac0f37e0001be707a74a7`.

> Debris physics target = persistent crumbs, not transient Chisel chunks.

Le premier spike avait appliqué la physique aux gros éclats transitoires du Chisel. Antoine visait les petites miettes persistantes qui restent après excavation. La correction autorisée réutilise le noyau de physique V2 pour ces seules miettes et restaure le spectacle P4-V1.

## Trois familles

1. **Transient Chisel chunks** : casse spectaculaire P4-V1, 3–6 mm, 1–5 par plaque, proportions Clay/Stone, couleurs et contraste conservés. Trajectoire courte et durée 0,51–0,69 s. Aucune physique terrain-aware, persistance, quantité de saleté ou interaction Blower ; même chemin en ON et OFF.
2. **Persistent physical crumbs** : petites écailles irrégulières Clay/Sandstone, nettement plus petites que les gros éclats. Petit saut/chute, relief courant, mini-rebond, glissement court, sommeil, puis **restent là**. Brush nettoie progressivement ; Blower réveille, soulève et transporte ; sortie du bloc ou R retire l'état.
3. **Fine Dust** : état, shader, génération et nettoyage existants conservés. L'excédent non retenu continue d'être déposé par le chemin existant.

## Génération et budgets

- Uniquement lors d'un retrait réel : jamais sur un impact sans matière retirée, ni depuis le spawn des effets visuels.
- Conserver la rétention **8 %**, la capacité par miette **0,02** et le principe **deux miettes par zone de naissance 24×24 texels**, partagé entre matériaux.
- Ajouter un plafond global raisonnable, initialement **128** à confirmer par profiling. Inclure les miettes au repos et en mouvement ; ne jamais recycler arbitrairement un déchet visible.
- Si budget saturé : refus de la nouvelle rétention, retour de tout l'excédent à Fine Dust. Aucun timer/fade automatique après sommeil ou en vol.
- Budget local = budget de **naissance**, sans imposer deux miettes par destination. Pas de migration complexe des buckets.
- Après disparition des effets transitoires : aucun gros cube 3–6 mm persistant ; seulement quelques petites saletés. Taille de travail commune ON/OFF : **2,2 mm maximum** pour la matrice ; Soil 1,4 mm conservé.

## Architecture et autorité

Réutiliser `TerrainDebris` comme noyau de mouvement appartenant à `LooseDebris`. Une seule physique active pour les miettes et un rendu MultiMesh borné. Pas de RigidBody/node par miette, collider dynamique, reconstruction de mesh ni scan du heightfield.

Le heightfield reste autoritaire. La position XYZ actuelle d'une miette est commune au rendu, à l'influence Brush/Blower et à la sortie du bloc. Sa quantité persistante et son budget de naissance restent suivis jusqu'au nettoyage/à la sortie. Une miette déplacée ne doit pas être nettoyée à son ancienne position.

La physique n'enlève/ajoute jamais de matériau structurel, n'altère ni fracture, ni Bone, ni exposition/Condition et ne bloque aucun objectif. Une même séquence d'outils donne exactement le même état structurel ON/OFF. Les positions et quantités nettoyées des miettes peuvent différer : c'est l'hypothèse comparée.

## Mouvement et nettoyage

- Gravité et paramètres data-driven à l'échelle du bloc.
- À chaque tick, X/Z → UV et `relief.height_at` à la **position courante**, avec correction du dessous orienté.
- Chute réelle dans une cavité : `final_y` significativement sous la hauteur de naissance ; aucune collision avec un ancien plan d'impact.
- Restitution Clay faible, Stone un peu plus sèche ; amortissement et glissement downhill limités, pas de pinball.
- Un endormi peut retomber si on creuse son support.
- Blower : impulsion/lift dédiés **`crumb_blower_impulse` / `crumb_blower_lift`**, pondérés par capsule/rayon/falloff existants et durée réelle. Assez puissant pour déplacer nettement de petites saletés.
- Blower ne fait pas disparaître directement une miette physique : quantité conservée jusqu'au nettoyage Brush ou à l'éjection.
- Sortie : libérer état/budget, émettre **une seule** fois `debris_ejected`, avec position/direction et quantité réelle restante. Aucun dépôt sur la table P6.
- Brush peut continuer à retirer progressivement la quantité ; aucune simulation supplémentaire de balayage.

## A/B

**F3 : Crumb Physics OFF / ON**. Les gros éclats restent P4-V1 dans les deux modes. OFF conserve placement/transport persistent historique ; ON ajoute gravité/contact/sommeil/Blower physique aux mêmes petites miettes et budgets.

Workflow : **OFF → R → même zone**, puis **ON → R → même zone**. R vide la saleté et conserve le mode choisi. F1 : mode, persistent crumbs, moving, sleeping, sondes terrain et CPU en µs. Mode ON au lancement.

## Validation

Conserver les tests historiques ; adapter explicitement seulement les attentes devenues obsolètes (taille des miettes et ancien compte global non borné). Ne pas relâcher les oracles d'outils, de géologie, de Bone, d'interface ou les seuils de performance.

Ajouter des tests de :

- éclats transitoires strictement P4-V1, identiques ON/OFF, sans état physique/persistant ;
- retrait réel, rétention, budget local/global, refus sans éviction et conservation des quantités ;
- sommeil persistant sans fade, reset, gravité, plat, cavité, rebord, pente et support excavé ;
- Blower : réveil, lift, direction, distance, rayon, vitesse bornée, indépendance du taux d'appel, sortie unique et budget libéré ;
- Brush à la nouvelle position, aucune interaction à l'ancienne ;
- rendu utilisant le vrai XYZ, aucun double état/spawn de gros morceaux ;
- RF/hauteurs packed, fracture, Bone/IDs, exposition/Condition/protections exactement identiques ON/OFF à plusieurs checkpoints ;
- F3/F1/R et pool/nœuds/meshes bornés.

Profiling réel 1080p, 1×/3× : **0, 32, 64 et cap choisi**, cavité, Blower sur cap, Brush cleanup, spam Chisel Clay/Stone, ON/OFF. Rapporter FPS, minimum sur une seconde, P95/max frame, CPU physique/Blower/MultiMesh et sondes. **≥60 FPS, P95 <16,67 ms.**

Baselines immuables : Brush **40/0,70/1,25**, Chisel **22/0,64/2,25/4,5 Hz**, Blower **60/0/1,0/clear 2,5**, Pick **7/0,24/1,5/6 Hz**. Bone : Skull → Skull → Ribs → Ribs = **tik/100 → DING/97 → tik/97 → DING/94**. V1 effort-aware, géologie, Dust, sons, proxies et caméra inchangés. Aucun procgen ni P5. Watchpoint poussière/arêtes toujours P6/P7.

## Checklist humaine exacte

A — CHISEL. Casser Clay/Sandstone.
> « Est-ce que j'ai retrouvé le punch P4-V1 des gros morceaux qui explosent ? »
Cible : **OUI**.

B — AFTERMATH. Attendre la fin des gros chunks transitoires.
> « Est-ce qu'il reste uniquement quelques petites saletés crédibles ? »
Cible : **OUI**.

C — CAVITY. Observer une petite miette générée au bord d'un trou.
> « Est-ce qu'elle tombe/se pose naturellement dans le relief ? »
Cible : **OUI**.

D — BLOWER. Souffler plusieurs petites miettes.
> « Est-ce que j'ai vraiment l'impression de chasser les déchets hors du trou ? »
Cible : **OUI**.

E — PERSISTENCE. Ne pas nettoyer, attendre plusieurs secondes.
> « Les petites miettes restent-elles en place jusqu'à ce que je décide de nettoyer ? »
Cible : **OUI**.

F — A/B. Crumb Physics OFF → R → même zone ; Crumb Physics ON → R.
> « La physique des PETITES miettes améliore-t-elle clairement le nettoyage ? »
Cible KEEP : **OUI**.

## Livraison / STOP

Actualiser le rapport, statut et décisions du Brain. Commits atomiques et push sur la branche existante. **PR #7 reste DRAFT, aucun merge.** Après implémentation, tests/performance et A/B prêts : **STOP pour verdict humain KEEP / SIMPLIFY / DROP**, sans P5. Ne pas déduire le plaisir des seuls tests automatiques.
