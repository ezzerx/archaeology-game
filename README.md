# ArchaeologyGame

**Working title modifiable.** ArchaeologyGame est un nom temporaire de projet, pas un titre commercial validé.

**Statut : Concept / pre-production.** Plateforme visée : Steam. Moteur envisagé : Godot, version à vérifier et choisir au démarrage du prototype.

## Vision

Un jeu cosy et satisfaisant d’archéologie, centré sur la fouille et la préparation de fossiles. La satisfaction répétée de *PowerWash Simulator* inspire la boucle : travailler une surface, observer une transformation tangible, puis avoir envie de continuer.

Le joueur travaille en **vue tabletop presque verticale**, sur un bloc de terre et de roche posé sur une table. Il retire progressivement les couches pour découvrir des os, identifier un spécimen et récupérer des fragments qui complètent son musée. Aucun monde ouvert ni personnage contrôlable.

**Fouille / nettoyage → découverte → identification / classification → récupération de fragments → collection → musée → nouvelle fouille.**

## Piliers

1. **Le game feel d’abord.** Résistance, poussière, éclats, sons, animation des outils et rythme de révélation rendent le geste agréable, même lorsque le fossile est déjà connu.
2. **Une matière crédible à travailler.** Plusieurs couches réagissent différemment ; elles s’abîment et se fissurent avant d’être retirées.
3. **Une découverte progressive.** L’identité peut rester inconnue, puis devenir probable avant d’être précise.
4. **Une collection physique visible.** Les fragments trouvés complètent réellement les squelettes exposés ; les parties manquantes restent manquantes.
5. **Un périmètre maîtrisé.** Valider un écran de fouille avant d’investir dans le musée, le volume de contenu ou la production artistique.

## Premier objectif : prototype v0.1

Un écran, un bloc, un fossile, trois outils, plusieurs matériaux, profondeur/destruction progressive, poussière, particules, sons, os découvrable et progression de spécimen.

Le critère de validation reste :

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

### Direction visuelle canonique du prototype

La cible retenue est désormais :

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

Le rendu doit ressembler à une illustration chaleureuse devenue interactive : table en bois, lampe chaude, carnet scientifique, matériaux avec relief, os ivoire, UI papier/bois/laiton et atmosphère de musée d’histoire naturelle.

Le pixel art n’est plus la cible de la V0.1.

## Documentation canonique

| Fichier | Usage |
|---|---|
| [CONCEPT](docs/CONCEPT.md) | Promesse, périmètre confirmé et hypothèses ouvertes |
| [GAMEPLAY_LOOP](docs/GAMEPLAY_LOOP.md) | Fouille, matériaux, outils, révélation et sensations |
| [ART_DIRECTION](docs/ART_DIRECTION.md) | Direction 2.5D tabletop, palette, caméra et références visuelles |
| [VISUAL_REFERENCES](docs/VISUAL_REFERENCES.md) | **Jeu de 4 références visuelles canonique + checksum du board** |
| [MVP_V0_1](docs/MVP_V0_1.md) | Résumé du prototype, périmètre et validation |
| [PROTOTYPE_V0_1_SPEC](docs/PROTOTYPE_V0_1_SPEC.md) | **Spécification détaillée canonique pour le développement de la V0.1** |
| [MUSEUM_SYSTEM](docs/MUSEUM_SYSTEM.md) | Galerie horizontale, fragments et progression |
| [TECH_NOTES](docs/TECH_NOTES.md) | Architecture conceptuelle et pistes Godot à vérifier |
| [ROADMAP](docs/ROADMAP.md) | Jalons conditionnés par les résultats du prototype |
| [Brain du projet](docs/brain/BRAIN.md) | Routage, statut et décisions pour reprendre le travail |

## État du dépôt

Le dépôt privé [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game) canonise la conception du projet.

La V0.1 est désormais suffisamment spécifiée pour démarrer l’implémentation, mais aucun code de jeu n’est considéré comme validé tant que le cœur de fouille n’a pas été testé manuellement.

Pour reprendre, lire [AGENTS.md](AGENTS.md), puis [PROTOTYPE_V0_1_SPEC.md](docs/PROTOTYPE_V0_1_SPEC.md), [VISUAL_REFERENCES.md](docs/VISUAL_REFERENCES.md), puis le [statut canonique](docs/brain/status.md).
