# ArchaeologyGame — Gameplay Prototype V0.1

**Status:** Prototype specification  

> **Current canon / source precedence — 2026-10-05:** this file is the foundational V0.1 specification and intentionally preserves historical sections. When a later phase conflicts with text below, use Antoine’s latest explicit decision, then the active phase brief/report, then the repository Brain. Current active work is P5 on `prototype/p5-loop-progression` / PR #8; read `docs/ORCHESTRATION_HANDOFF.md`, `docs/dev/P5_BRIEF.md` and `docs/dev/P5_REPORT.md`. In particular, old references to three tools, automatic fragment recovery, Soil persistent dust and `Restart Specimen` are superseded.

**Project phase:** Pre-production  
**Target:** PC / Steam  
**Engine:** Godot 4.x, version stable à figer au démarrage du développement  
**Purpose:** Valider le cœur de gameplay avant toute production du jeu complet.

**Addendum P5 — 2026-10-05 (prioritaire sur les sections historiques)** : P4 est validé et mergé. La session B-17 comporte désormais cinq outils : Brush, Chisel, Air Blower, Precision Pick et **Forceps [5]**. [P5_BRIEF](dev/P5_BRIEF.md) fait autorité ; [P5_REPORT](dev/P5_REPORT.md) décrit l’implémentation, les tests et la checklist humaine.

- **Exposure ≠ Cleanliness ≠ Condition.** La propreté mesure le film retiré sur l’os anatomique actuellement exposé ; un nouvel os révélé peut faire baisser ce ratio sans resalir les cellules déjà propres.
- Classification automatique monotone : Unknown ; Vertebrate remains à5 % global ou10 % d’un composant ; Possible Theropod avec Spine15 % + Hind Limb10 % ; Likely small theropod avec Skull35 % après le stade précédent.
- Composants : Hidden<10 % ; Detected≥10 % ; Exposed≥50 % ; Prepared si exposition≥80 % et propreté≥80 %.
- Objectifs acquis dans n’importe quel ordre : **Prepare the skull** (exposition60 % et propreté50 %), révéler60 % du squelette, récupérer2/2 fragments. Les seuils P5 restent provisoires jusqu’au tuning P7.
- **§21 est remplacé** : aucune récupération automatique. Deux fragments indépendants, hors totaux anatomiques, deviennent READY à90 % d’exposition avec une collerette locale dégagée. Forceps saisit, soulève et transporte ; relâcher sur le plateau récupère, ailleurs restitue. Aucun retrait de terrain/film ni dégât.
- **§23 est remplacé** : `Preparation Complete` capture les statistiques une seule fois. `Keep Cleaning` reprend la préparation sans reset et conserve l’accès à `Archive Specimen`. L’archive utilise les valeurs finales, arrête les outils et affiche `Museum records updated` puis `Prepare Another Block`.
- Pour P5, ce dernier bouton et R réinitialisent exactement **le même B-17**. La file de spécimens et la sélection de site sont futures ; aucun musée persistant, galerie, économie ou autre fossile ici.
- Temps completion→archive, statistiques aux deux instants et actions supplémentaires restent en mémoire/F1. Aucune télémétrie réseau. **STOP pour test humain, PR #8 DRAFT ; pas de P6.**

**Addendum P4 — 2026-10-03 :** la deuxième passe corrective autorise explicitement un quatrième outil prototype, **Precision Pick [4]**, pour la finition des restes attachés, sûr sur l’os à titre provisoire. Cette exception au périmètre initial de trois outils est décrite dans [P4_REPORT](dev/P4_REPORT.md) et [P4_MATERIAL_REACTION_DECISION](dev/P4_MATERIAL_REACTION_DECISION.md). Aucun P5 ni merge P4 autorisé.

**Simplification finale P4 — 2026-10-03 :** Pick devient un micro-Chisel sûr à impacts immobiles (clic/maintien). Grammaire joueur : matière attachée / saleté ; Soil → Brush, matrice dure → Chisel, détails → Pick, mess → Brush/Blower. Règle verrouillée : **Dust may obscure detail, never material identity**. L’ivoire Bone reste identifiable sous la poussière ; outils à orientation fixe et éclats peu obstructifs. Cette décision remplace les attentes antérieures de grattage du Pick et de classification des débris, sans lancer P5.

## 1. Objectif du prototype

**P4 FINAL FEEL — 2026-10-04 :** la composition issue du test A/B restaure les éclats transitoires Chisel A et le souffle visible Blower B, avec quantité persistante plafonnée, Soil/Pick récents et ancien angle fixe. Le petit son Bone ne marque plus chaque reveal : uniquement la première découverte par reset ; gros son uniquement au hit direct avec perte de condition ; sinon son du matériau travaillé. Source de vérité : [P4_FINAL_FEEL_TARGET](dev/P4_FINAL_FEEL_TARGET.md). Retest en sept points ; aucun merge, P4-V ou P5 autorisé.

La V0.1 n'est **pas une vertical slice** d'ArchaeologyGame.

Elle ne doit répondre qu'à une seule question :

> **Est-ce que fouiller ce bloc est suffisamment satisfaisant pour que le joueur ait envie de continuer à gratter alors qu'il sait déjà qu'un fossile se trouve dessous ?**

Si oui, le projet possède un cœur de gameplay.

Si non, aucun musée, arbre de progression, système économique ou catalogue de dinosaures ne doit être développé pour compenser.

### Expérience recherchée

Le joueur doit ressentir successivement :

**curiosité → travail de la matière → premier indice → découverte → précaution → révélation → satisfaction.**

Scénario émotionnel de référence :

> Je retire de la terre.  
> La matière réagit agréablement.  
> Je rencontre une couche plus résistante.  
> Je change d'outil.  
> Un petit morceau blanc apparaît.  
> Le son change.  
> « Attends… c'est un os ? »  
> Je prends un outil plus délicat.  
> La forme se révèle progressivement.  
> Je veux voir la suite.

## 2. Direction visuelle canonique V0.1

La direction pixel-art est abandonnée **pour le prototype gameplay**.

La référence devient :

### **2.5D stylisée — tabletop — orthographique**

Le rendu doit donner l'impression d'une illustration chaleureuse devenue interactive.

Pas photoréaliste. Pas low-poly visible. Pas cartoon exagéré. Pas pixel-art.

### Références conceptuelles

La philosophie est proche de :

- *Assemble with Care* → objet central et manipulation tactile ;
- *A Little to the Left* → tableau fixe soigneusement composé ;
- *Potion Craft* → outils manipulés physiquement ;
- *Strange Horticulture* → carnet, spécimens, identification, atmosphère scientifique cosy.

ArchaeologyGame doit développer son identité propre autour de :

**terre + pierre + os + lumière chaude + matériel scientifique + musée d'histoire naturelle.**

## 3. Caméra

Caméra fixe.

Perspective : **orthographique, presque verticale**.

Angle cible : environ **82–86°** par rapport au sol plutôt qu'un 90° mathématique.

Cela permet de conserver la sensation « vue du dessus » tout en laissant percevoir :

- les creux ;
- les morceaux de roche ;
- l'épaisseur du bloc ;
- les ombres ;
- le relief des os.

Aucune rotation caméra. Aucun déplacement libre.

Un très léger zoom automatique ponctuel pourra être testé lors d'une découverte, mais **aucun camera shake agressif**.

## 4. Composition de l'écran

À 1920 × 1080 :

```text
┌───────────────────────────────────────────────────────────┐
│ OBJECTIFS                         DOSSIER SPÉCIMEN         │
│                                                           │
│              ┌────────────────────────────┐               │
│ carnet       │                            │  matériaux     │
│              │                            │               │
│              │       BLOC DE FOUILLE      │               │
│              │                            │               │
│ fragments    │                            │  notes         │
│              └────────────────────────────┘               │
│                                                           │
│                    BARRE D'OUTILS                         │
└───────────────────────────────────────────────────────────┘
```

Le bloc doit occuper environ **55–65 % de la surface utile**.

Il reste l'élément dominant à tout instant. Le décor ne doit jamais voler l'attention à la fouille.

## 5. Le poste de travail

Le niveau entier est **une table**.

Éléments décoratifs V0.1 :

- table en bois ;
- lampe de bureau vert sombre / laiton ;
- carnet de terrain ;
- règle scientifique ;
- étiquette du spécimen ;
- boîte à fragments ;
- quelques pinceaux ;
- deux ou trois bocaux ;
- crayon ;
- petite loupe ;
- quelques feuilles végétales en bord d'écran.

Ils sont essentiellement décoratifs. Pas d'interaction complexe.

Objectif : faire comprendre immédiatement :

> « Je suis installé à un poste de préparation paléontologique. »

## 6. Le spécimen V0.1

Un seul spécimen.

### Specimen B-17

Petit théropode fictif / non précisément identifié.

Cela évite d'avoir besoin d'une reconstruction scientifiquement parfaite dès le prototype.

Au lancement :

> **Specimen B-17**  
> Classification: Unknown

Le squelette comprend visuellement :

- une partie du crâne ;
- plusieurs vertèbres ;
- une portion de cage thoracique ;
- un membre postérieur ;
- quelques os isolés ;
- deux petits fragments récupérables.

Le joueur **ne voit aucune silhouette du squelette complet au départ**.

## 7. Le bloc

Le bloc est rectangulaire et fait environ **1,1 × 0,7 m fictif**.

Il comporte plusieurs reliefs irréguliers.

L'épaisseur excavable visuelle doit être suffisante pour produire de véritables creux.

### Matières

| Matière | Fonction |
|---|---|
| Loose Soil | introduction et gratification immédiate |
| Compact Clay | première résistance |
| Sandstone | matière dure entourant certains os |
| Hard Rock | petite zone secondaire, expérimentation facultative |

Hard Rock ne doit jamais bloquer l'objectif principal de la V0.1.

## 8. Principe technique de la matière

La matière ne fonctionne pas comme :

> clic → texture disparaît.

Chaque zone possède une **épaisseur/résistance**.

Conceptuellement :

```text
100
 ↓ outil
82
 ↓
61
 ↓
37
 ↓
12
 ↓
0 → couche suivante visible
```

Visuellement :

**intact → marqué → endommagé → fissuré/émietté → retiré.**

Lorsqu'une zone est retirée, un creux doit réellement apparaître ou être simulé de façon convaincante.

## 9. Architecture recommandée du bloc

Sous le rendu 3D, le prototype utilise une simulation contrôlée.

### Carte de travail

Résolution de départ : **1024 × 640 cellules/texels environ.**

Chaque cellule connaît au minimum :

```text
material
remaining_depth
surface_height
bone_underneath
bone_component
dust_amount
```

Les outils n'agissent que dans la petite région autour du curseur.

### Rendu

Approche recommandée :

**height map + material masks + shader + géométrie subdivisée.**

La height map pilote le relief.

Les material masks déterminent :

- couleur ;
- roughness ;
- normal ;
- particules ;
- son ;
- résistance.

Le squelette est placé **sous la surface excavable**.

Lorsqu'une hauteur devient suffisamment faible, l'os apparaît.

## 10. Outils V0.1

La spécification initiale prévoyait trois outils ; **P4/P5 portent la barre à cinq** : Soft Brush, Chisel, Air Blower, Precision Pick et Forceps. Les descriptions historiques ci-dessous sont complétées par l'addendum prioritaire et le brief P5.

### Tool 1 — Soft Brush

Usage principal : **terre meuble + nettoyage délicat autour des os.**

Interaction : maintenir clic gauche + déplacer la souris.

Le pinceau suit physiquement le curseur. Le curseur standard disparaît au-dessus du bloc. Les poils montrent un léger mouvement/bending.

#### Comportement

- Loose Soil : **très efficace**
- Compact Clay : **très peu efficace**
- Sandstone : **inefficace**
- Bone : **sans risque**

Rayon : environ **35–45 px de simulation** avec falloff doux.

Le retrait dépend légèrement de la vitesse du mouvement. Un mouvement continu doit produire de petites traînées naturelles plutôt qu'un cercle parfait.

### Tool 2 — Chisel

Usage : **Compact Clay + Sandstone + éventuellement Hard Rock.**

Interaction : maintenir clic gauche.

Le chisel réalise des petits impacts successifs.

Cadence cible : **4–5 impacts/seconde**.

Chaque impact provoque :

- petite fissure ;
- micro-éclats ;
- poussière ;
- variation sonore ;
- diminution localisée du matériau.

#### Efficacité

- Loose Soil : faible intérêt
- Clay : forte
- Sandstone : moyenne
- Hard Rock : faible mais perceptible
- Bone : **dangereux**

### Tool 3 — Air Blower

Usage : **nettoyer les résidus**.

L'air ne doit pratiquement pas retirer de matière structurelle.

Il retire :

- poussière ;
- grains libres ;
- petits débris ;
- résidus masquant les os.

Interaction : clic maintenu + déplacement.

Le jet suit légèrement la direction du mouvement.

Boucle recherchée :

> casser → poussière → souffler → révéler.

## 11. Matériau : Loose Soil

Aspect : terre brune granuleuse.

Comportement :

- bouge facilement ;
- produit beaucoup de petits grains ;
- peu de gros morceaux ;
- disparition rapide.

Temps cible pour nettoyer une zone circulaire standard au pinceau : **~0,5–1 seconde**.

Audio : frottement doux et granulaire.

VFX :

- poussière fine ;
- petits grains ;
- particules légères.

Objectif : **gratification immédiate**.

## 12. Matériau : Compact Clay

Aspect : ocre / rouge brun, plus homogène et dense.

Au pinceau : presque rien ne se passe.

Au chisel : petites plaques se décollent.

Progression visuelle :

```text
surface intacte
↓
marques
↓
microfissures
↓
fragmentation
↓
morceau qui saute
```

Temps cible au chisel : **~1–1,5 seconde pour une petite zone.**

Audio plus mat : `tac`, `scrrk`, `tac`.

## 13. Matériau : Sandstone

Aspect : beige clair.

Plus cassant que l'argile.

Au chisel :

> petits impacts → fissure → morceau qui se détache.

Temps cible : **~1,5–2,5 secondes par petite zone.**

Les fragments peuvent être plus gros.

Audio plus sec et cristallin.

## 14. Hard Rock

Présent sur seulement **5–10 % du bloc**.

Très résistant.

Sert à tester :

- feedback d'inefficacité ;
- différence sonore ;
- potentiel futur des outils plus puissants.

Le chisel peut l'altérer lentement.

Il n'est pas nécessaire de le retirer pour terminer le prototype.

## 15. Poussière

La poussière est un véritable état du gameplay, pas uniquement un effet visuel.

Certaines actions augmentent `dust_amount`.

La poussière peut légèrement masquer :

- couleur du matériau ;
- fissures ;
- bord des os.

Le pinceau en retire une partie. L'Air Blower en retire énormément.

## 16. Les os

Les os doivent être immédiatement distincts sans être blanc fluorescent.

Palette : **ivoire légèrement chaud**, avec nuances de beige.

Surface plus lisse que la pierre.

Ils doivent capter la lumière différemment.

L'os est probablement l'élément le plus important visuellement de tout le jeu.

## 17. Premier contact avec un os

Moment critique.

Lorsqu'un outil agressif atteint pour la première fois une cellule située juste au-dessus d'un os :

### Le premier contact est protégé.

Aucun dégât.

Le joueur entend **un petit “tik” différent**.

Quelque chose qui suggère : ce n'est pas de la pierre.

Le jeu affiche discrètement :

> 🦴 **Bone detected**  
> Delicate material underneath.

Puis :

> Soft Brush recommended.

Le joueur doit instinctivement arrêter le chisel.

## 18. Bone Condition

Après découverte, l'os peut être endommagé.

Valeur : **100 % au départ.**

- Soft Brush : 0 dommage
- Air Blower : 0 dommage
- Chisel sur os exposé : environ **-3 % par impact direct**

Le premier contact caché reste gratuit.

Pas de Game Over. Pas de destruction définitive dans V0.1.

Condition finale simplement enregistrée.

Exemple :

> Specimen Condition  
> **94 % — Excellent**

## 19. Révélation

Un os n'est pas considéré comme découvert dès qu'un seul pixel apparaît.

Chaque composant possède une surface.

Exemple :

```text
Skull
Visible surface: 3%
→ aucune notification

Visible surface: 12%
→ Skull fragment detected

Visible surface: 50%
→ Skull partially exposed

Visible surface: 90%
→ Skull prepared
```

Les seuils pourront être ajustés.

## 20. Mystère / identification

Au début :

### UNKNOWN SPECIMEN

Après une petite quantité d'os :

> Vertebrate remains

Après découverte de vertèbres + membre :

> Possible classification: Theropod

Après dégagement partiel du crâne :

> Likely small theropod

La V0.1 peut s'arrêter ici.

Il n'est pas nécessaire d'identifier une espèce réelle.

## 21. Fragments récupérables

Deux petits fragments osseux indépendants sont présents.

Ils deviennent **READY** lorsque :

- au moins 90 % de leur surface est visible ;
- la couronne locale de matrice est entièrement dégagée selon le test déterministe P5.

**P5 remplace la récupération automatique par Forceps [5].** LMB sur READY saisit et soulève le fragment ; le drag suit la souris. Relâcher sur le plateau le récupère ; relâcher ailleurs le remet en place, toujours READY. Aucune excavation, aucun retrait de film ni dégât. Les totaux du squelette principal sont inchangés.

Feedback :

> **Fragment recovered — 1/2**

Le fragment apparaît ensuite dans le petit plateau à côté du bloc.

Le décor de la table évolue grâce aux actions du joueur.

## 22. Objectifs V0.1

Panneau en haut à gauche :

### Current Objective

- ☐ Prepare the skull — exposition du crâne ≥60 % et propreté ≥50 %
- ☐ Reveal 60 % of the skeleton
- ☐ Recover both fragments

Ils peuvent être réalisés dans n'importe quel ordre.

## 23. Condition de fin

Lorsque les trois objectifs sont atteints :

P5 déclenche la carte une seule fois et fige les statistiques de completion. Les outils s'arrêtent pendant la carte ; aucune transition de lumière ou de son supplémentaire n'est requise dans cette passe.

Carte :

> **Preparation Complete**
>
> Possible classification: Small Theropod
>
> Skeleton revealed: 67 %
>
> Bone cleanliness: 61 %
>
> Fragments recovered: 2/2
>
> Condition: 94 %

Deux boutons :

- **Keep Cleaning**
- **Archive Specimen**

Le bouton le plus important est **Keep Cleaning**.

Keep Cleaning reprend exactement le même état, avec tous les outils et un bouton Archive Specimen toujours disponible dans le dossier. L'archive capture les statistiques finales actuelles, stoppe les outils et affiche **Specimen Archived — Museum records updated.** puis **Prepare Another Block**. Ce bouton remplace le rôle principal de Restart Specimen et réinitialise le même B-17 pour P5 ; une file de spécimens ou une sélection de site viendra plus tard.

## 24. Test comportemental clé

Nous voulons savoir :

> Le joueur continue-t-il à nettoyer alors que le prototype lui a déjà dit qu'il avait terminé ?

C'est notre meilleur signal de game feel.

## 25. Durée d'une session

Première partie cible : **7 à 12 minutes.**

Rythme indicatif :

```text
0:00 — découverte du pinceau
1:00 — première couche dégagée
2:00 — arrivée sur clay
3:00 — utilisation du chisel
4:00 — premier contact os
5:00 — changement de comportement
6:00 — crâne commence à apparaître
8:00 — squelette identifiable
10:00 — objectifs terminés
```

## 26. Barre d'outils

Bas de l'écran.

Cinq slots fonctionnels en P5 :

```text
[1] Soft Brush
[2] Chisel
[3] Air Blower
[4] Precision Pick
[5] Forceps
```

Sélection via clic ou touches 1 / 2 / 3 / 4 / 5. La molette conserve le zoom ; les modificateurs debug restent décrits dans le rapport P4.

Le slot sélectionné reçoit une lumière chaude subtile.

## 27. Outil physique à l'écran

Quand un outil est sélectionné, **on voit réellement l'outil au-dessus du bloc**.

Pas seulement une icône curseur.

Le manche suit légèrement la souris avec inertie. Le point de contact reste précis.

L'outil peut avoir quelques dizaines de millisecondes de retard visuel sans retarder l'interaction réelle.

Cela lui donne du poids.

## 28. Feedback du curseur

Sur le bloc : curseur système invisible.

Lorsqu'une précision supplémentaire est nécessaire : petit cercle de contact presque transparent.

Sur l'UI : curseur standard.

## 29. Particules

Trois familles principales.

### Soil particles
Très petites, nombreuses, légères.

### Clay particles
Plus épaisses, petites plaques.

### Stone fragments
Moins nombreux, plus lourds, rebondissent éventuellement une fois.

Puis disparaissent après quelques secondes.

Ne jamais transformer l'écran en tempête de particules.

**La découverte doit rester visible.**

## 30. Audio — priorité très élevée

Le prototype doit avoir de l'audio avant d'avoir une UI parfaitement finie.

Chaque matériau doit être identifiable presque les yeux fermés.

### Brush + soil
`frrrshhh`, `shhhh`, `frrt`

### Clay
`scrrk`, `krch`

### Chisel + sandstone
`tik`, `tok`, `krak`

### Bone contact
Un `tik` plus clair, plus fin, différent de la pierre.

### Air blower
`ffffwoosh`, court et doux.

## 31. Variations audio

Chaque action utilise plusieurs variantes.

Au minimum **4–6 samples** par famille d'impact importante.

Pitch aléatoire très léger : environ ±3–5 %.

Volume lié à l'intensité.

Le son du pinceau dépend de la vitesse de déplacement.

## 32. Musique

Pas nécessaire au premier greybox.

Lorsque ajoutée : très discrète, ambient chaleureux.

Elle ne doit jamais masquer les sons de matière.

**La matière est la bande-son principale du gameplay.**

## 33. Éclairage

Source principale : **lampe de bureau chaude en haut à gauche.**

Température visuelle ~3200–3800 K.

Remplissage très léger plus froid venant de l'environnement.

La matière creusée produit des ombres locales.

L'os nouvellement exposé accroche légèrement la lumière.

Aucun effet surnaturel.

## 34. Palette

Dominante :

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

Rouge : vrais avertissements.

## 35. UI

Style : **natural-history field notebook**.

Panneaux :

- papier ;
- cartes ;
- bois ;
- petits cadres laiton.

Ne pas donner l'impression d'un jeu médiéval/fantasy.

Référence mentale :

> musée d'histoire naturelle + carnet scientifique + atelier cosy.

## 36. Dossier du spécimen

En haut à droite.

Au début :

```text
SPECIMEN B-17

Classification:
Unknown

Skeleton exposure
██░░░░░░░░  4%

Bone condition
██████████ 100%
```

Le texte évolue sans changer de fenêtre.

## 37. Panneau Materials

Petit panneau :

```text
MATERIALS

● Loose Soil
● Compact Clay
● Sandstone
● Hard Rock
```

Le matériau actuellement sous l'outil peut être légèrement mis en avant.

Pas besoin d'afficher des statistiques.

## 38. Tutorial

Aucun tutoriel modal.

Au lancement, soft brush déjà équipé.

Petit texte :

> Hold LMB and move the mouse to brush.

Il disparaît dès que le joueur le fait.

Quand clay apparaît :

> The brush barely affects compact material.

Le slot Chisel effectue une petite animation discrète.

Quand l'os est détecté :

> Delicate material underneath.

C'est tout.

## 39. Pas de mains humaines

Pour V0.1 : **aucune main / bras du personnage.**

Cela évite animation, rig, clipping, IK, personnalisation.

L'outil seul communique suffisamment l'action.

## 40. Scope strict — ce qui N'EST PAS développé

Pas de :

- musée jouable ;
- galerie scrollable fonctionnelle ;
- monnaie ;
- boutique ;
- XP ;
- niveaux ;
- personnages ;
- dialogue ;
- monde ouvert ;
- carte ;
- inventaire complet ;
- génération procédurale ;
- multiples fossiles ;
- sauvegarde ;
- Steam achievements ;
- cloud save ;
- gamepad ;
- options graphiques avancées ;
- onboarding complet ;
- histoire ;
- animations de visiteurs ;
- économie du musée.

Même si certaines idées semblent rapides à ajouter.

**V0.1 = le bloc.**

## 41. Architecture Godot recommandée

Conceptuellement :

```text
PrototypeMain
│
├── TableEnvironment
│
├── ExcavationBlock
│   ├── SurfaceMesh
│   ├── HeightMap
│   ├── MaterialMap
│   ├── DustMap
│   └── FossilAssembly
│
├── ToolController
│   ├── Brush
│   ├── Chisel
│   └── AirBlower
│
├── FXController
│   ├── Particles
│   ├── Debris
│   └── Audio
│
├── DiscoverySystem
│
├── ObjectiveSystem
│
└── UI
    ├── Objectives
    ├── SpecimenDossier
    ├── MaterialPanel
    └── ToolBar
```

Les systèmes doivent rester découplés.

Le bloc ne contient pas les règles d'UI.

Les outils ne connaissent pas les objectifs. Ils génèrent des événements :

```text
bone_first_contact
bone_component_revealed
fragment_recovered
material_removed
condition_changed
objective_completed
```

## 42. Données configurables

Les valeurs de game feel ne doivent pas être hardcodées.

Créer des Resources Godot ou équivalent.

### MaterialDefinition

```text
id
resistance
brush_multiplier
chisel_multiplier
air_multiplier
particle_profile
audio_profile
visual_profile
```

### ToolDefinition

```text
radius
power
cadence
falloff
bone_damage
particle_multiplier
```

## 43. Debug mode

Touche **F1** :

- material map ;
- height map ;
- bone mask ;
- dust map ;
- tool footprint ;
- bone exposure % ;
- FPS ;
- condition.

Touche **R** : reset instantané du bloc.

## 44. Performance cible

Prototype : **1080p / 60 FPS stable.**

Interaction perçue : immédiate.

Objectif de latence : **< 50 ms** entre mouvement et réaction visible.

## 45. Priorité de développement

### P0 — Interaction brute
- caméra ;
- bloc ;
- raycast ;
- curseur ;
- outil capable de modifier une map.

### P1 — Matière
- depth ;
- trois matériaux ;
- différences de résistance ;
- creusement.

À la fin de P1 : on doit déjà pouvoir « creuser ».

### P2 — Outils
- brush ;
- chisel ;
- blower ;
- changement outils ;
- falloff ;
- cadence.

### P3 — Fossile
- modèle sous la surface ;
- exposure ;
- bone detection ;
- condition.

À la fin de P3 : **premier véritable test du concept.**

### P4 — Game feel
- particules ;
- debris ;
- outil physique ;
- sound design ;
- dust ;
- éclairage.

### P5 — UI et progression
- objectives ;
- specimen dossier ;
- classification ;
- fragments ;
- completion card.

### P6 — Art pass
Reproduire réellement la direction des concept arts :
- table ;
- lampe ;
- textures ;
- carnet ;
- objets ;
- UI ;
- palette ;
- composition.

### P7 — Tuning
Aucun nouveau système. Seulement :
- vitesse ;
- résistance ;
- rayons ;
- sons ;
- quantité de poussière ;
- feedbacks ;
- rythme de découverte.

## 46. Définition de Done V0.1

La V0.1 est terminée lorsque :

1. le bloc peut être excavé continuellement ;
2. les matériaux se sentent différents ;
3. les trois outils ont chacun une utilité évidente ;
4. des creux apparaissent visuellement ;
5. la poussière peut masquer puis révéler ;
6. l'os peut être découvert progressivement ;
7. le joueur reçoit un feedback particulier au premier contact ;
8. le chisel peut endommager un os exposé ;
9. deux fragments peuvent être récupérés ;
10. le dossier passe de Unknown à Theropod probable ;
11. les trois objectifs peuvent être complétés ;
12. le joueur peut choisir **Keep Cleaning** ;
13. le prototype tourne à 60 FPS ;
14. audio, VFX et lumière donnent déjà une vraie personnalité au geste.

## 47. Test utilisateurs

Première vague : **5 personnes minimum.**

Ne pas expliquer le jeu avant.

Observer :

- comprennent-elles comment brosser ?
- changent-elles spontanément d'outil ?
- reconnaissent-elles qu'elles viennent de rencontrer un os ?
- ralentissent-elles naturellement près de l'os ?
- utilisent-elles le blower sans qu'on leur dise précisément où ?
- ont-elles envie de révéler plus que l'objectif ?

Après partie :

- « La fouille était-elle satisfaisante ? » — note /5
- « Quel outil préférais-tu utiliser ? »
- « Quand as-tu compris que tu avais trouvé un os ? »
- « As-tu eu envie de continuer après la fin ? »
- « Qu'est-ce qui t'a paru frustrant ? »

## 48. KPI de validation interne

### Feu vert

Au moins **4 joueurs sur 5** donnent **4/5 ou plus** à la satisfaction du nettoyage.

Et au moins **3 joueurs sur 5 continuent volontairement à nettoyer après l'apparition de Preparation Complete.**

Ce deuxième KPI mesure directement l'hypothèse centrale.

## 49. Philosophie V0.1

Quand Astra hésite entre :

> ajouter une feature

et

> rendre le pinceau 20 % plus agréable,

choisir **le pinceau**.

Quand Astra hésite entre :

> coder le musée

et

> donner au sandstone un meilleur son de fracture,

choisir **le sandstone**.

Quand Astra hésite entre :

> ajouter un quatrième outil

et

> rendre la découverte d'un os mémorable,

choisir **l'os**.

## 50. North Star

La V0.1 doit réussir ce moment :

Le joueur frappe doucement du grès.

**tok.**

Encore.

**tik.**

Une fissure apparaît.

Un morceau tombe.

Quelque chose de légèrement ivoire apparaît au fond du creux.

Le joueur frappe encore une fois.

**tik.**

Le son n'est plus le même.

> **Bone detected.**

Il relâche immédiatement la souris.

Il sélectionne le pinceau.

La musique est presque imperceptible.

Quelques grains partent.

Une dent apparaît.

Puis une autre.

Puis le contour d'une mâchoire.

Et le joueur pense :

> **« Oh merde… je veux voir le crâne entier. »**

**C'est ça, ArchaeologyGame.**
