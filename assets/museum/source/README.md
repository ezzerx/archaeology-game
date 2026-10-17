# Sources originales du mobilier

Les sources ici sont conservées sans retouche et versionnées avec leur provenance.
Le fichier `.gdignore` évite leur import automatique dans Godot. Une version de
travail destinée au rendu sera créée séparément lors de l'intégration.

## Dossier de dépôt utilisateur

`C:\Users\antoi\Documents\ArchaeologyGame-Assets\Tripo\museum`

Ce dossier local, indépendant des worktrees, sert à déposer les futurs exports.
Après dépôt, Antoine peut simplement indiquer le nom du fichier dans le chat.
Les nouveaux fichiers ne sont pas automatiquement sauvegardés sur GitHub :
les importer explicitement ici, vérifier leur intégrité et les versionner.
Conserver un nom distinct pour chaque génération ; ne pas écraser les sources.

## B–17

- Source : `tripo-studio/b17/museum_b17_stand_pilot.glb`.
- Provenance et empreinte : [provenance.json](tripo-studio/b17/provenance.json).
- GLB 2.0 vérifié ; 84 656 triangles, un maillage, un matériau et trois images
  embarquées. Aucune ressource externe référencée par les images ou les buffers.
- Copie identique à l'export reçu, vérifiée par SHA-256.
- Paramètres conseillés dans la fiche Studio ; la réception du GLB ne confirme
  pas chaque option sélectionnée à la génération.
- L'inspection technique du conteneur ne vaut pas validation artistique.

## Copie de travail du pilote
La copie assets/museum/models/b17_stand.glb est importable et reste identique à
l'original par SHA-256. Transformations et correction de matériau se font dans
scripts/experiments/exhibition/b17_stand.gd. La revue source a repéré une inscription
inventée au dos, à reprendre avant finalisation ; voir le rapport
[du pilote](../../../docs/dev/ISSUE51_B17_TRIPO_PILOT.md).
