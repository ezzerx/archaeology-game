# #28 — Le bloc préparé devient une pièce du musée

## Expérience
Retrouver son travail, avec les marques que l’on reconnaît : une bordure laissée
en grès, un petit reste de poussière, une fissure localisée. La galerie et sa
netteté ont été validées ; cette passe remplace ses exemples par le résultat réel.

À l’atelier, les trois préparations et leurs outils restent identiques. La fin
reste choisie au seuil existant, avec possibilité de continuer la finition.
« Conserver cette préparation » enregistre le bloc, puis « Voir au musée »
ouvre son présentoir. Les emplacements sans préparation restent vides et ne
révèlent pas une future espèce. Un retour à l’atelier permet un nouvel essai.

Le dernier bloc terminé de chaque espèce occupe son emplacement, indépendamment
du meilleur score historique. Chaque tentative 3D reste conservée sur disque.
Les anciennes photos, scores et distinctions restent dans leur stockage actuel,
sans migration ni suppression. L’interface de sélection des anciennes tentatives
ne fait pas partie de cette passe.

## Réalisation
Archive statique versionnée de la géométrie et des textures de rendu : matrice,
empreinte naturelle, matières, poussière adhérente, dégâts et ombres limitées aux
os exposés. Aucun contrôleur de préparation n’est exécuté dans la galerie.
Index distinct dans user://prepared_exhibits ; écriture vérifiée, index temporaire
et sauvegarde précédente. Un échec conserve le bloc ouvert et autorise de réessayer.

Godot choisit son renderer au démarrage. Cette passe conserve Compatibility pour
l’atelier et Forward+ pour la galerie, via une relève de processus avec accusé de
démarrage. Cela implique un changement de fenêtre et un chargement. L’unification
du renderer et une transition continue restent une mission de comparaison séparée.
Les scènes d’essai et lanceurs existants restent disponibles ; les nouveaux
lanceurs sont Launch-Prepare-For-Museum.cmd et Launch-Museum.cmd.

## Limites
Pas de nouvelles caisses, de placement libre, d’extraction ou de changement des
règles de fin et du feeling. Les particules transitoires ne deviennent pas des
objets de collection. La galerie utilise son éclairage propre : conserver les
matières et le relief ne signifie pas conserver les pixels de l’atelier.

## Acceptation / essai humain
- Terminer B–17 et une ammonite avec des zones de finition reconnaissables.
- Reconnaître leur relief, la matière restante, la poussière et les dégâts exposés.
- Aucun os enterré ni ombre d’os enterré ne doit apparaître.
- Fermer puis relancer le musée : retrouver les mêmes objets.
- Finir une nouvelle tentative moins bien préservée : voir ce dernier bloc,
  en conservant les archives historiques.
- Vérifier les trois familles, les emplacements vides, les échecs/reprises
  d’enregistrement et l’absence de modification des sauvegardes historiques.
- Revue humaine de la PR avant fusion ; les contrôles automatisés ne la remplacent pas.
