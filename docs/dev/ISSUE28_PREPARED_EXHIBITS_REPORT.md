# #28 — Préparations réelles exposées

## Résultat
Le nouveau parcours relie les trois préparations validées à la galerie :
**Conserver cette préparation → Voir au musée → Retour à l’atelier**.

Le présentoir montre la dernière tentative terminée de l’espèce, même avec un
score moins bon. L’archive conserve le maillage réel, les hauteurs, les matières,
la poussière adhérente, les dégâts localisés et les ombres des seuls os exposés.
Les limites du bloc servent au cadrage ; une marge accueille son épaisseur sur
le support. Les places sans préparation restent vides et anonymes.

Les archives photographiques et meilleurs résultats existants ne sont ni migrés
ni modifiés. Ils ne contiennent pas la géométrie permettant de reconstituer
fidèlement leurs anciens blocs. Le nouveau musée se remplit donc avec les
préparations terminées depuis ce nouveau parcours.

## Essayer
- Double-cliquer **Launch-Prepare-For-Museum.cmd** : terre compacte C par défaut,
  sélecteurs des trois préparations conservés en attendant les futures caisses.
- Terminer un bloc, ou poursuivre sa finition au-delà du seuil existant.
- Choisir **Conserver cette préparation**, puis **Voir au musée**.
- Inspecter le bloc et ses traces, fermer, puis double-cliquer
  **Launch-Museum.cmd** pour vérifier sa conservation.
- Faire une autre tentative : la dernière occupe le présentoir.
- **Retour à l’atelier** démarre une nouvelle préparation.

Le changement de préparation non terminé garde la confirmation existante.
Une sauvegarde échouée empêche de remplacer la seule copie vivante et permet
de réessayer depuis le panneau de fin.

## Vérifications
Godot 4.7.2, RTX 5080, pilotes NVIDIA 610.88. Stockages QA isolés.

| Vérification | Résultat |
|---|---|
| Trois préparations terminées avec les outils réels, gel/rechargement, contrôle des cartes et des os enterrés | 68 contrôles, 0 échec |
| Sauvegarde partielle (94 % dégagement, 91,79 % nettoyage), reprises, historique, écriture concurrente, corruption | 18 contrôles, 0 échec |
| Galerie alimentée par B–17, ammonite marine et concrétions | 9 contrôles, 0 échec |
| Galerie vide et navigation sans révéler de pièces | 4 contrôles, 0 échec |
| Galerie d’étude précédente, Forward+ | 95 contrôles, 0 échec |
| Chargement des ressources et scripts | 312 contrôles, 0 échec |
| Relève effective vers la galerie puis vers l’atelier | Réussie dans les deux sens |

Pour chaque famille, la capture de l’archive rechargée est identique pixel pour
pixel à la préparation vivante, à caméra et lumière identiques dans le renderer
Compatibility. Cette preuve seule ne vérifiait pas la colorimétrie en Forward+. La simulation
source est désactivée et ses géométries masquées pendant la comparaison.
Le relief figé reste inchangé après réinitialisation de la source.

Les scènes de vérification terminent les blocs par des parcours d’outils
systématiques, puis ajoutent un contact de dégât local pour contrôler sa copie.
Ces captures prouvent la restitution ; elles ne mesurent pas une durée humaine
et ne remplacent pas la validation de l’aspect d’un bloc préparé librement.

Les empreintes des anciens records, distinctions et préférences d’affichage
sont identiques avant/après les tests.

## Preuves
- [Galerie réelle](evidence/issue28/01-overview.png)
- [B–17 en inspection](evidence/issue28/04-b17-close.png)
- [Ammonite marine](evidence/issue28/06-marine.png)
- [Ammonite avec concrétions](evidence/issue28/03-ammonite.png)
- [Galerie vide](evidence/issue28/empty.png)
- [Contrôles de restitution](evidence/issue28/exhibits.json)
- [Contrôles de sauvegarde](evidence/issue28/storage.json)
- [Mesure galerie](evidence/issue28/gallery.json)

## Stockage et limites
Les nouvelles archives sont dans **user://prepared_exhibits** : scènes binaires
compressées, index JSON versionné et sauvegarde précédente. L’index n’est validé
qu’après relecture de la scène ; un hash détecte une scène endommagée.
L’écriture utilise un verrou entre processus et recharge l’index avant chaque
nouvelle tentative. Les tentatives précédentes restent sur disque ; leur
sélection dans une interface est hors périmètre.

Les trois scènes mesurées occupent environ **7 à 10 Mo chacune**. Le format v1
dépend des textures importées et inclusions de shaders du projet : toute
évolution incompatible devra prévoir une migration. Aucune purge automatique.

La galerie garde Forward+ et l’atelier Compatibility. La relève préserve le
mode et la taille de fenêtre et attend un accusé de chargement avant de fermer
le processus précédent. Mesures : **8,28 s** vers la galerie et **6,74 s** vers
l’atelier. Ce chargement visible reste une limite du prototype.

Avec deux vrais blocs et l’ammonite marine affichée, la galerie 1920×1080 mesure
**6,06 ms médiane / 6,32 ms p95** hors plafond, soit environ 165 FPS au point
médian. La cible 240 FPS de galerie n’est pas atteinte ; le relief complet est
conservé. Le plafond et la physique de préparation restent inchangés.

Pas de nouvelle caisse, d’extraction, de tuning des outils ou de modification
des sources Tripo. Revue humaine requise avant fusion.


## Correction de continuité des matières après essai humain

Antoine confirme que la conservation fonctionne, puis signale un sédiment
marine presque blanc dans la galerie. Ce blanchiment n’était pas une variation
artistique voulue.

La palette procédurale marine/concrétions était calculée en sRGB comme dans
l’atelier, mais envoyée directement au rendu linéaire Forward+. Elle est
désormais décodée à la sortie du calcul ; la modulation par la matière source
se fait également dans son espace d’origine. La branche Compatibility reste
identique. B–17 retourne sa matière d’origine avant cette conversion.

Le choix utilise le signal [OUTPUT_IS_SRGB de Godot](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html#global-built-ins).
Aucune retouche de la lumière du musée, de la palette choisie, des outils,
de la géométrie ou des masques de couverture. Les archives v1 référencent
l’inclusion corrigée : aucune réécriture ni nouvelle préparation nécessaire.

### Preuves du correctif

- [Même archive du joueur, avant](evidence/issue28/marine-color-before.png)
  et [après](evidence/issue28/marine-color-after.png), même caméra et même lumière.
  Son fichier binaire conserve exactement le même hash après relecture.
- Nuancier natif isolant huit états : matière compacte, marne, grains libres,
  couche profonde, contact sombre, matrice à concrétions, croûte et coupe fraîche.
  Ancien shader Forward+ : 7 écarts détectés, jusqu’à 0,288 par canal.
  Shader corrigé : 17 contrôles, aucun échec ; écart maximal moyen par canal
  inférieur à 0,0042 (environ 1,1 niveau sur 255).
- Nuancier Compatibility avant/après : PNG identiques octet pour octet.
- Galerie réelle : 9 contrôles sans échec, inspection des trois familles.
- Chargement des ressources : 313 contrôles, aucun échec.

Les mesures du nuancier isolent le matériau, sans éclairage ni tonemapping.
Les scènes complètes gardent naturellement leurs ambiances différentes ;
ces chiffres ne promettent pas une identité des pixels entre atelier et musée.
La capture de galerie pendant cet essai cohabitait avec la galerie ouverte du
joueur : ses temps GPU ne constituent pas une nouvelle mesure de performance.

Reproduction (Godot natif, depuis la racine, processus successifs) :
```powershell
& $Godot --path . --rendering-method gl_compatibility --script res://tests/run_issue28_colors.gd
& $Godot --path . --rendering-method forward_plus --script res://tests/run_issue28_colors.gd -- --reference=res://work/issue28/colors/gl_compatibility.json
```

Résultats : [Compatibility](evidence/issue28/colors-compatibility.json),
[Forward+ corrigé](evidence/issue28/colors-forward.json),
[contrôle négatif ancien shader](evidence/issue28/colors-before-forward.json),
[archive existante inchangée](evidence/issue28/colors-existing-archive.json).


## Retour suivant : poussière et contours au zoom
Diagnostic et corrections complémentaires dans
[le rapport de restitution rapprochée](ISSUE28_EXHIBIT_DETAIL_FIX.md).
