# ArchaeologyGame

**Working title modifiable.** ArchaeologyGame est un nom temporaire de projet, pas un titre commercial validé.

**Statut : Concept / pre-production.** Plateforme visée : Steam. Moteur envisagé : Godot, version à vérifier et choisir au démarrage du prototype.

## Vision

Un jeu cosy et satisfaisant d’archéologie, centré sur la fouille et la préparation de fossiles. La satisfaction répétée de *PowerWash Simulator* inspire la boucle : travailler une surface, observer une transformation tangible, puis avoir envie de continuer.

Le joueur travaille en **vue strictement du dessus / tabletop** sur un bloc de terre et de roche posé sur une table. Il retire progressivement les couches pour découvrir des os, identifier un spécimen et récupérer des fragments qui complètent son musée. Aucun monde ouvert ni personnage contrôlable.

**Fouille / nettoyage → découverte → identification / classification → récupération de fragments → collection → musée → nouvelle fouille.**

## Piliers

1. **Le game feel d’abord.** Résistance, poussière, éclats, sons, animation des outils et rythme de révélation rendent le geste agréable, même lorsque le fossile est déjà connu.
2. **Une matière crédible à travailler.** Plusieurs couches réagissent différemment ; elles s’abîment et se fissurent avant d’être retirées.
3. **Une découverte progressive.** L’identité peut rester inconnue, puis devenir probable avant d’être précise.
4. **Une collection physique visible.** Les fragments trouvés complètent réellement les squelettes exposés ; les parties manquantes restent manquantes.
5. **Un périmètre maîtrisé.** Valider un écran de fouille avant d’investir dans le musée, le volume de contenu ou la production artistique.

## Premier objectif : prototype v0.1

Un écran, un bloc, un fossile, trois matériaux, trois outils, destruction progressive, particules, sons, os découvrable et jauge de progression. Le critère de validation est :

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

La direction artistique privilégiée est un pixel art premium, détaillé et chaleureux. Une alternative en 2D illustrée haute résolution sera comparée sur le prototype jouable avant de figer ce choix.

## Documentation canonique

| Fichier | Usage |
|---|---|
| [CONCEPT](docs/CONCEPT.md) | Promesse, périmètre confirmé et hypothèses ouvertes |
| [GAMEPLAY_LOOP](docs/GAMEPLAY_LOOP.md) | Fouille, matériaux, outils, révélation et sensations |
| [ART_DIRECTION](docs/ART_DIRECTION.md) | Atmosphère, deux pistes visuelles et méthode de choix |
| [MVP_V0_1](docs/MVP_V0_1.md) | Périmètre minimal et critères de validation |
| [MUSEUM_SYSTEM](docs/MUSEUM_SYSTEM.md) | Galerie horizontale, fragments et progression |
| [TECH_NOTES](docs/TECH_NOTES.md) | Architecture conceptuelle et pistes Godot à vérifier |
| [ROADMAP](docs/ROADMAP.md) | Jalons conditionnés par les résultats du prototype |
| [Brain du projet](docs/brain/BRAIN.md) | Routage, statut et décisions pour reprendre le travail |

## État du dépôt

Le dépôt privé [ezzerx/archaeology-game](https://github.com/ezzerx/archaeology-game) canonise le brainstorming au 2026-09-30. La demande de canonisation fournie par Antoine est la référence principale ; la conversation « jeu archéologie » sert de contexte complémentaire.

Cette étape ne contient aucune implémentation du jeu : ni projet Godot, ni scènes, scripts ou assets de production. La roadmap décrit le travail futur ; sa présence ne lance pas le développement. Le `.gitignore` prépare le versionnement Godot et `.gitattributes` normalise les fichiers texte.

Pour reprendre, lire [AGENTS.md](AGENTS.md), puis le [statut canonique](docs/brain/status.md). Les hypothèses de conception restent explicitement séparées des décisions confirmées.
