# Publication de la version jouable — 2026-10-14

Antoine valide le B-17 modelé puis demande explicitement de mettre GitHub à jour
et d’intégrer la dernière version jouable à main. Le lancement normal utilise
maintenant `scenes/p6a37_modeled_skeleton.tscn` plutôt que l’ancienne scène P4/P5.

## Contenu consolidé

Squelette 3D complet du B-17 partiel (49 pièces), ivoire chaud, ombres des seuls
os réellement dégagés ; Brush sur Film réactif, dégâts localisés, binds corrigés,
complétion atteignable et distinction 100/100 persistante. Les interactions et
la direction artistique ont reçu les verdicts humains consignés dans les rapports.
La distinction elle-même reste sans verdict humain explicite.

`Launch-Game.ps1` démarre l’entrée normale avec Godot 4.7.2 stable. Ouvrir
`project.godot` dans l’éditeur et lancer le projet produit la même scène,
initialement recouverte. README actualisé pour le lancement et les commandes.
Le nom de configuration historique est conservé pour ne pas déplacer les
répertoires user:// et perdre la visibilité des préférences/archives existantes.

Les scènes, masters et preuves des anciens essais restent versionnés. Les six
scripts d’export historiques choisissent désormais explicitement leur scène,
indépendamment de l’entrée normale. Ce travail n’a pas reconstruit les anciens
ZIP ou les pages privées de distribution, qui restent des livraisons historiques.
Quatre UID de scripts générés par l’éditeur sont versionnés pour l’hygiène du dépôt.

## Vérifications de publication

- Lancement réellement par défaut, sans argument de scène : headless et natif
  Compatibility / RTX 5080, Godot 4.7.2 stable, aucune erreur.
- Smoke intégration de l’entrée configurée : bonne source, 49 pièces, 25 404
  cellules, zéro exposition initiale, Condition 100, aucun caster enterré,
  inspection fermée, Brush accepté et fréquences conservées.
- P5 : 128 contrôles ; P6A3.7 : 85 contrôles, zéro échec.
- Sélection de scène des exports Python : 8 combinaisons (ancien/nouveau défaut,
  LF/CRLF, deux exports) ; syntaxe de 5 scripts PowerShell et 4 substitutions
  de scène vérifiées. Exports binaires complets non relancés ici.
- Preuves : `docs/dev/evidence/main-publication-2026-10-14/verification.json`.
  Les 461 contrôles artistiques précédents restent dans `evidence/p6a37/`.

Les mesures de performance précédentes restent non isolées ; aucun nouveau
verdict 240 FPS soutenus ou durée de fouille n’est déduit de ces smokes.

## Suite discutée

Sound Design différé à la demande d’Antoine, crédits Claude indisponibles.
Lampe orientable, silhouette naturelle des blocs et variété entre préparations
sont des sujets de cadrage, sans implémentation dans cette publication.
La gate et les références GitHub actuelles vivent uniquement dans le Brain du dépôt.
