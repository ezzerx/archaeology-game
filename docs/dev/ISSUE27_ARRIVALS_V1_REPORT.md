# #27 — Réception et ouverture des colis, V1

## Résultat

La réception remplace le choix abstrait pour le lanceur `Launch-Arrivals.cmd`
et l'export Windows V1. Trois caisses Tripo sont installées sur le comptoir :
sélection avec focus, loquet indépendant, couvercle articulé, puis accès à la
préparation correspondante. Les raccourcis 1/2/3, E, Échap et Alt+Entrée sont
complémentaires aux gestes souris.

Les étiquettes décrivent lot, provenance et matrice sans nommer l'espèce.
Les aperçus intérieurs sont des captures 3D des vrais blocs au départ, entièrement
couverts ; ils n'exécutent aucune simulation de préparation. L'association des
colis aux trois préparations est fixe. La compacte conserve sa variante C.

Le retour aux arrivages demande confirmation avant l'abandon d'un travail non
conservé. Annuler conserve la préparation en mémoire. Un archivage échoué bloque
la sortie jusqu'à conservation réussie. La galerie permet de revenir aux colis.
Les lanceurs historiques conservent leur parcours.

## Assets et décor

`assets/arrivals/source/tripo-studio/<objet>/` conserve chaque original intact,
sa provenance avec SHA-256 et un master Blender ajusté. `source/.gdignore` exclut
ces archives de l'import et de l'export du jeu. Les copies runtime sont dans
`assets/arrivals/models/`, les vrais blocs couverts dans `covered_blocks/`.
Les références restent dans `docs/visual-references/arrivals/` ; aucun doublon
des accessoires du musée n'est créé.

| Objet | Triangles source | Triangles runtime | Textures runtime |
| --- | ---: | ---: | --- |
| Corps | 80 152 | 36 068 | 2K |
| Couvercle | 40 283 | 18 126 | 2K |
| Comptoir | 121 386 | 60 693 | 2K |

Sources 4K préservées. Blender 4.3.2 ajuste dimensions/pivots et réduit les copies.
Les scripts de production sont dans `tools/arrivals/`. Les aperçus de blocs utilisent
une grille de 81 920 triangles au lieu des 1 310 720 du bloc jouable : les cartes
de relief et les matières sont conservées, les os complètement enfouis sont exclus.
Les grilles et les règles des préparations jouables ne changent pas. Les réglages recommandés
dans le pack ne sont pas présentés comme des réglages prouvés des exports reçus.

Architecture éditable : dalles de pierre, enduit crème, soubassement vert,
passage arqué, calages et pièces mécaniques. Fenêtre, livres, appliques et fougère
proviennent des modèles existants du musée. L'éclairage suit la même direction
chaude ; cette V1 reste à juger sur PC avec la planche approuvée.

## Parcours et sauvegardes

Réception et musée utilisent Forward+, atelier Compatibility. Le passage reste
une relève de processus avec accusé de chargement, conservation du format de
fenêtre et du répertoire de collection. Il peut changer de fenêtre ; le renderer
commun et la transition continue restent hors périmètre.

Le test d'archivage a révélé un défaut de détection du verrou sous Linux : l'API
Godot ne suit que ses processus enfants. La détection utilise maintenant `/proc`
sous Linux et reconnaît le processus courant. Le comportement Windows utilise
l'API existante. Aucun format de sauvegarde ni règle de préparation ne change.

## Vérifications

- 75 contrôles de réception : vrai raycast souris sur loquet/couvercle, glissement,
  fermeture initiale, bloc masqué, association des trois blocs, focus perdu,
  blocage de préparation, couvercle dans le cadre, arguments de lancement, deux rapports d'écran.
- 22 contrôles d'atelier : lancement direct du troisième colis, trois familles,
  variante C, retour avec confirmation, annulation sans perte et blocage d'une
  archive non enregistrée.
- 18 contrôles de stockage existants : échec et reprise d'archivage, historique,
  dernier résultat même moins bon, concurrence, corruption et anciennes données.
- Export avec moteur et templates officiels Godot 4.7.2 ; PE x64 et CRC du ZIP
  vérifiés. Le paquet final a aussi été chargé depuis un répertoire isolé :
  scène de réception, trois aperçus optimisés et exclusion des sources vérifiés ;
  ressources atelier/musée présentes. L'exécutable Windows n'a pas été exécuté sur ce cloud Linux.

Les arguments des relèves de processus sont vérifiés ; le parcours complet entre
fenêtres et sa durée restent à éprouver sous Windows.

La caméra recule légèrement et remonte pendant l’ouverture pour garder le haut
du couvercle visible. Les captures sont réalisées en OpenGL logiciel sous Linux :
le premier rendu Forward+ n’a pas abouti dans le cloud. Elles contrôlent le
cadrage et les modèles, sans valider l’éclairage Forward+ sur le PC cible.

Les scripts de test, résultats JSON et captures constituent les preuves du candidat.
Les contrôles automatisés ne valident ni le plaisir d'ouverture ni les performances
sur le PC d'Antoine. Aucun FPS matériel n'est déduit du rendu logiciel du cloud.

## Essai humain

Examiner la vue d'ensemble et le focus ; ouvrir chaque caisse à la souris et
avec E ; choisir puis annuler un retour atelier ; conserver une préparation et
vérifier sa présence au musée après relance. Relever confort des gestes, durée
des transitions, éclairage, collisions visuelles et fluidité. Les corrections
restent sur la PR #54 ; le statut canonique porte le gate de validation.

## Livraison du candidat

Le ZIP `builds/issue27/ArchaeologyGame-Arrivals-V1-Windows.zip` est conservé
dans le workspace cloud (496 966 065 octets), SHA-256
`80cbe6a35c546a5457200ea22c8d0ce775c714efc34bd71ea82f91b8c033016a`.
Il n'est pas suivi dans le dépôt de jeu. L'hébergement du téléchargement a échoué :
limite d'archive locale de 256 MiB, puis erreur distante
`Cannot create a string longer than 0x1fffffe8 characters`.
Les vérifications d'assemblage des 60 parties concernent le paquet local,
pas un téléchargement publié.

Pour reprendre localement : récupérer `codex/27-arrivals`, utiliser Godot 4.7.2,
puis `Launch-Arrivals.cmd`. Le script `tools/arrivals/export_native.py`
reproduit le paquet natif. Les captures et résultats sont dans
[le dossier de preuves](evidence/issue27/README.md).

Diagnostic de la publication du paquet complet :
- Site : `appgprj_6ace1afd5f2c81919e82f40e93b3ef32`.
- Version : `appgprj_6ace1afd5f2c81919e82f40e93b3ef32~appgver_abb590213af88191ba048db586f18be6`.
- Premier déploiement : `appgdep_6ad6321683848191a86ad52bda3f9b24`, clonage interrompu (`early EOF`).
- Nouvelle tentative de la même version : `appgdep_6ad63356552081918ea3ff3f2d808827`, limite de chaîne ci-dessus.

La revue légère est publiée séparément ; elle signale explicitement l'absence
de téléchargement Windows. Les anciens binaires et la version complète restent
récupérables dans l'historique du dépôt du site.
