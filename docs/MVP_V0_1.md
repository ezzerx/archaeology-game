# Prototype v0.1 — Fossil Cleaning Prototype

**Statut : spécifié, non développé.** Ce document décrit la prochaine expérience à réaliser lorsqu’un développement sera demandé.

## Question à résoudre

> Est-ce que j’ai envie de continuer à gratter alors que je sais déjà ce qu’il y a dessous ?

Une réponse positive valide le cœur de sensation, pas la viabilité commerciale ni le jeu complet.

## Périmètre obligatoire

| Élément | Résultat attendu |
|---|---|
| Un écran | Tabletop strictement du dessus, sans personnage ni déplacement |
| Un bloc | Surface multicouche travaillable directement |
| Un fossile | Os révélés progressivement sous la matière |
| Trois matériaux | Résistance, réactions et sons perceptiblement différents |
| Trois outils | Fonctions distinctes et changement immédiat compréhensible |
| Matière destructible | Usure locale, états visuels intermédiaires, retrait et couche suivante |
| Game feel | Animation de l’outil, particules, poussière, petits éclats et sons de matière |
| Découverte | Contact avec l’os identifiable et retour de nouvelle révélation |
| Progression | Jauge lisible de dégagement / nettoyage du fossile |

### Sélection de départ proposée

Trois matériaux : **terre meuble, argile compacte, grès / roche tendre**. Trois outils : **soft brush, chisel, air bulb / blower**, conformément à la piste du brainstorming. Cette sélection est un point de départ de test, pas une décision de catalogue définitive.

Le pinceau travaille la terre ; le burin travaille les couches compactes et le grès ; la soufflette évacue les résidus et clarifie la surface. La poussière est un résidu visuel / nettoyable, pas une quatrième couche géologique. Tester que chaque outil apporte un geste utile et que la précision près des os reste agréable.

Le retour de contact avec l’os est obligatoire. Un système complet de dommages, résine et condition persistante ne l’est pas.

## Hors périmètre

Pas de menu complexe, monde ouvert, personnage, musée complet, sauvegarde avancée, économie, intégration Steam, succès, large catalogue ni « 30 dinosaures ». Pas d’identification encyclopédique complète ou de pipeline industriel d’assets à cette étape.

Une information simple de découverte peut être testée. Le mystère reste compatible avec un fossile unique : connaître le contenu après une première tentative doit encore laisser le geste plaisant.

## Ordre de réalisation futur

1. Vérifier la version stable de Godot et choisir le rendu de test.
2. Construire une petite surface multicouche qui s’use progressivement.
3. Ajouter les trois outils et leurs réactions distinctes.
4. Travailler particules, sons, contact avec l’os et rythme de révélation.
5. Ajouter la jauge, puis rejouer le bloc connu.
6. Comparer pixel art et 2D illustrée sur cette interaction.

Chaque étape sert le test de sensation ; aucune n’est exécutée par la présente canonisation.

## Validation manuelle

- Chaque outil produit un effet visible sans délai perceptible ; un outil inadapté n’efface pas arbitrairement la roche.
- Les matériaux se distinguent à la vue et au son ; la matière montre une progression avant de disparaître.
- L’os émerge par petites révélations ; les particules n’en masquent pas les indices.
- Le contact os / outil et la découverte d’un fragment se reconnaissent ; les récompenses ne se répètent pas à chaque passage.
- La jauge progresse avec le dégagement réel et atteint la complétion selon une règle définie pour ce bloc.
- Une seconde fouille du même contenu donne encore envie de poursuivre sans dépendre uniquement de la surprise.

Recueillir le verdict d’Antoine, les moments satisfaisants et les gestes frustrants. Si le cœur échoue, reprendre résistance, sons, visuels et rythme avant le musée. Si le cœur fonctionne, passer au prochain jalon de la [roadmap](ROADMAP.md).
