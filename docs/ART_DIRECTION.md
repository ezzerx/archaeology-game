# Direction artistique

## Décision canonique — 2026-10-01

Pour le prototype gameplay v0.1, la direction visuelle retenue est :

> **2.5D stylisée — tabletop — caméra orthographique presque verticale**

Le pixel art premium reste une inspiration historique du projet mais **n'est plus la cible du prototype**. La décision part désormais du gameplay : la fouille doit permettre des bords libres, des cavités, du relief, des ombres locales, des matériaux qui se fissurent et une révélation très progressive des os.

La référence détaillée du prototype est [PROTOTYPE_V0_1_SPEC](PROTOTYPE_V0_1_SPEC.md).  
Le jeu de références visuelles canonique est défini dans [VISUAL_REFERENCES](VISUAL_REFERENCES.md).

## Intention

Le rendu doit donner l'impression d'une **illustration chaleureuse devenue interactive** :

- table de préparation paléontologique comme niveau entier ;
- bloc central en 3D / 2.5D avec profondeur perceptible ;
- caméra fixe, quasiment du dessus ;
- lumière chaude d'une lampe de bureau ;
- carnet scientifique, étiquettes, outils et plateaux à fragments ;
- interface papier / bois / laiton ;
- os ivoire légèrement chaud et plus lisses que la pierre ;
- poussière, petits éclats et réactions localisées des matériaux.

Le résultat ne doit être ni photoréaliste, ni low-poly visible, ni cartoon exagéré, ni pixel-art.

## Références de philosophie visuelle

Ces jeux servent de références d'intention et de structure, sans copie d'assets, scènes ou compositions :

- *Assemble with Care* — objet central et manipulation tactile ;
- *A Little to the Left* — composition fixe, claire et soigneusement mise en scène ;
- *Potion Craft* — outils manipulés directement et importance du geste ;
- *Strange Horticulture* — bureau, carnet, spécimens, identification et atmosphère scientifique cosy.

L'identité propre d'ArchaeologyGame repose sur :

> **terre + pierre + os + lumière chaude + matériel scientifique + musée d'histoire naturelle**

## Références conceptuelles validées

La famille de concept arts générée le 2026-10-01 dans la conversation de conception constitue la référence visuelle de travail. Son ordre, son rôle et le checksum du board canonique sont consignés dans [VISUAL_REFERENCES.md](VISUAL_REFERENCES.md).

Les quatre axes sont :

1. **Écran de fouille principal** — bloc central multi-matériaux sur table, lumière chaude, barre d'outils basse, panneaux papier.
2. **Moment actif de fouille** — pinceau visible au-dessus du bloc, poussière en mouvement, cavité marquée et message **Bone detected!**.
3. **Fouille avancée / identification** — squelette largement exposé, dossier du spécimen, fragments récupérés et carnet de comparaison.
4. **Musée scrollable** — galerie / carousel sans avatar, squelette incomplet, silhouettes fantômes des parties manquantes et panneau **Missing Fossil Parts**.

Ces images sont des **mood/concept references**, pas des assets de production.

## Caméra

- fixe ;
- orthographique ;
- presque verticale ;
- cible indicative : **82–86°** par rapport au sol ;
- aucune rotation ni navigation libre ;
- éventuel micro-zoom contextuel uniquement s'il améliore une découverte.

La légère inclinaison sert à rendre lisibles les creux, l'épaisseur, les ombres et le relief des os tout en conservant l'impression de vue du dessus.

## Matière et relief

Les matériaux doivent se distinguer par leur **texture, comportement, son et relief**, pas seulement leur couleur.

Matières de la v0.1 :

- Loose Soil — brun granuleux ;
- Compact Clay — ocre / rouge brun, dense ;
- Sandstone — beige clair, cassant ;
- Hard Rock — gris sombre, très résistant ;
- Bone — ivoire chaud, surface plus lisse.

La matière montre son usure avant de disparaître :

**intact → marqué → endommagé → fissuré / émietté → retiré**

Le creusement doit générer ou simuler une vraie variation de profondeur avec ombres locales.

## Palette

Dominantes :

- bois brun chaud ;
- ambre ;
- terre rouge ;
- grès crème ;
- vert bouteille ;
- laiton ;
- parchemin ;
- ivoire.

Accent UI : ocre / or désaturé.  
Vert : validation / condition.  
Rouge : avertissements réels uniquement.

## Éclairage

Source principale : lampe de bureau chaude en haut à gauche.

Cible indicative : **3200–3800 K**, avec un fill très léger plus froid.

L'os nouvellement révélé doit accrocher légèrement la lumière sans glow surnaturel.

## UI

Direction : **natural-history field notebook**.

Matériaux d'interface :

- papier ;
- cartes / fiches ;
- bois ;
- petits détails laiton.

L'UI doit évoquer un musée d'histoire naturelle et un atelier scientifique, jamais une interface médiévale / fantasy.

## Son et atmosphère

Le son fait partie de la DA.

Les familles sonores doivent permettre d'identifier presque sans regarder :

- terre ;
- argile ;
- grès ;
- roche ;
- os ;
- air / poussière.

La matière est la bande-son principale. La musique, lorsqu'elle sera ajoutée, reste très discrète.

## Règle de production

Le prototype ne doit pas chercher à reproduire immédiatement la finition des concept arts. Ordre :

1. prouver le creusement et la révélation ;
2. prouver le game feel ;
3. seulement ensuite réaliser l'art pass vers cette DA.

Si un choix esthétique réduit la qualité ou la précision de la fouille, **le gameplay gagne**.


## Production timing — clarified 2026-10-01

The DA is a core product risk, but the roadmap deliberately keeps the canonical phase order:

> **P3 → P4 → P5 → P6 Art Pass → P7**

There is no separate `ART0` roadmap phase.

### P4 — sensory gameplay feedback, not production art

P4 may introduce visual/audio elements that are necessary to judge the feel of excavation:

- local dust / particles;
- material reaction readability;
- basic tool presence;
- simple fragments / debris;
- lighting response around cavities and bone;
- discovery feedback;
- sound families.

These can remain placeholder / prototype quality.

The purpose is to judge **game feel**, not to reproduce the final concept art.

### P5 — complete loop, functional UI

P5 implements the complete excavation loop and usable UI/progression:

- objectives;
- specimen dossier;
- classification;
- fragments;
- completion card.

The UI may still be functional / greybox. Do not delay the loop to perfect the visual language.

### P6 — dedicated Art Pass

P6 is the point where DA becomes a primary development priority.

P6 begins with **P6A — Visual Direction / Production Spike**, then **P6B — V0.1 Art Pass**.

P6A validates the pipeline on one representative slice before broad application:

- 3D/2.5D balance;
- materials and texturing;
- lighting;
- tool and prop workflow;
- UI visual language;
- image-generation / Higgsfield / Blender / texture-tool workflow;
- consistency and GPU budget.

P6B then applies the validated language to the full V0.1 slice.

The objective is to spend production-art effort only once the gameplay structure is mature enough that DA has more leverage than another gameplay feature.

### Pareto rule

> **Do the minimum visual work necessary to validate gameplay until final-quality visuals become the highest-leverage next step.**

This avoids both extremes:

- rushing into expensive art too early;
- treating DA as cosmetic polish left until the end.

No external art tool is canonized yet.
