# P6A4.9 — Finition de la poche friable

## GO et critères de clôture

Antoine autorise les quatre points proposés : apparition progressive, matière
matte lisible, souffle court avec une fin claire, et zéro ou une poche variable
par préparation. Il demande une revue réelle et des itérations internes jusqu’à
un résultat satisfaisant par rapport à cette vision.

La dynamique P6A48 est validée humainement. Conserver les outils, B-17, Brush,
dégâts localisés, collection et lumière. Son dédié, génération de toutes les
strates, nouveaux outils et musée restent distincts.

## Contrat de la passe

- Choisir le volume au départ par graine reproductible, dans des enveloppes
  géologiques configurables. Rejeter un volume dangereux plutôt que le découper
  selon l’anatomie. Même graine au reset ; cinq cas de revue, dont une absence.
- Aucune silhouette cachée. Dans la dernière peau d’argile seulement : grains
  inclus, puis petite libération au vrai contact. Une seule aide contextuelle.
- Grain mat, trois tailles/agrégats, transition morcelée. Lire le front et la
  matière compacte dans les creux avec la lumière acceptée.
- Particules venant du vrai retrait, dont de courts déplacements roulés ; pas de
  scintillement ni disparition totale du volume caché. Finir les seuls grains
  accessibles sans poursuite de restes invisibles.
- Revue native des états couvert/contact/soufflage/fond, comparaison P6A48,
  contrôles adverses de placement et occlusion, puis livraison jouable.

## Preuves et revue interne

### Revue et corrections réalisées

- Comparaison native P6A48/P6A49 sur **le même terrain réellement excavé** :
  grain rond et répétitif remplacé par un mélange facetté de trois échelles,
  moins uniforme et mat. Normales locales discrètes ; pas d’émission ni de
  déplacement géométrique ajouté pour donner un faux volume.
- La première recette arrivait aux grains dès le premier impact dans les quatre
  cas. Après revue, le toit a été enfoui de 3.06 mm supplémentaires : le premier
  impact garde une peau d’argile et l’ouverture intervient au second dans le
  parcours central contrôlé. Les paramètres des outils restent identiques.
- Revue de la transition, du souffle réel et du fond dans les quatre implantations.
  Le dernier grain libre peut finir localement ; le gris/brun compact revient
  après évacuation. Les plages orange restantes sont de la matrice réelle, pas
  un contour peint suivant le fossile. Le bord carré de certaines captures vient
  de la bande de coups native choisie pour mesurer le rythme, pas du volume généré.
- Deux défauts du harnais corrigés : mesurer le retrait maximal dans l’ouverture
  réelle plutôt qu’un centre parfois encore couvert ; enregistrer cette mesure
  avant le reset. Les prises de vue du fond retrouvent aussi le zoom après R.
- Les effets proviennent du retrait effectivement commis. Un groupe natif
  capturé compte 70 grains, dont 22 roulants, et contribue à 477 pixels visibles.
  Tout disparaît après relâchement ; pas d’agrégats flottants persistants.

Je considère ce candidat suffisamment cohérent pour la dernière revue humaine
prévue. Les contrôles et ma revue des captures ne constituent pas le verdict
humain sur le plaisir, la fréquence de production ou la validation artistique.

## Implémentation et rythme

La recette `config/p6a49_pocket.tres` expose les enveloppes admissibles, axes,
profondeurs, probabilité et budget de recherche. Elle génère le volume complet
avant le contrôle de couverture Bone. Un volume dangereux est rejeté entier ;
son fond n’est jamais remonté cellule par cellule selon l’anatomie. Les cinq
préparations de revue utilisent les graines 49301–49305 : quatre volumes et une
absence. Le choix a lieu à la création du bloc ; aucun outil ne le fait apparaître.

Dans les quatre cas : couverture initiale **14.0–21.8 mm**, épaisseur granulaire
**1.35–16.95 mm**, forme/rotation/toit/fond différents. La géologie et les hauteurs
initiales du bloc restent identiques à P6A41. Les inclusions visibles concernent
seulement les derniers 2.24 mm réels au-dessus du toit ; pas de silhouette à
travers une couverture épaisse. La première découverte déclenche une unique
indication contextuelle pendant le lancement, sans bandeau permanent ni message
répété à chaque reset.

Un demi-seconde de souffle natif après découverte retire **11.9–16.3 % du volume
granulaire total**, avec un abaissement local maximal de **16.9–20.0 mm**, incluant
la mince croûte déchaussée réellement atteinte par le jet. Après une bande ouverte
par 22–26 impacts natifs, trois balayages de 0.65 s évacuent **99.87–100 % des
grains initialement accessibles**. Environ 74.8–95.4 % du volume total est alors
retiré ; le restant couvert attend une ouverture normale. Ces parcours servent
d’oracles comparables, pas de promesse de durée de fouille humaine.

L’assistance finale ne concerne qu’une colonne déjà libre, dans le vrai jet,
avec un poids suffisant et moins de 0.408 mm de grains après le pas courant.
Elle ne nettoie pas hors rayon et ne coupe pas le substrat compact. La règle
acceptée de très mince croûte déchaussée dans le jet reste conservée.

Effets séparés des miettes et de la poussière Brush : agrégats facettés mats,
petites tailles variées, roulement court et poussière réduite. Pool de 176 grains
maximum ; au plus 12 échantillons du vrai sol par frame pour le roulement ; aucun
collider ni ombre ajoutée. Les effets gardent le son de souffle existant. Le Sound
Design dédié reste différé.

## Vérification

**708 contrôles, zéro échec** sur Godot 4.7.2 stable :

| Suite | Contrôles |
| --- | ---: |
| P6A49 logique, préparation complète et interactions | 197 |
| P6A49 rendu natif et occlusion | 71 |
| P6A49 effets natifs en mouvement | 6 |
| Référence P6A48, hook partagé inchangé par défaut | 163 |
| P1 picking / relief | 52 |
| P5 session / collection | 128 |
| P4V2 miettes | 91 |

Preuves JSON et captures sélectionnées : `docs/dev/evidence/p6a49/`. La revue
native complète produit 41 captures dans `work/test-logs/p6a49/`, plus la prise
en mouvement. Les essais de recette sur 32 graines indépendantes donnent 28
volumes sûrs et 4 absences, zéro découpe autour des os. Une enveloppe rendue
volontairement dangereuse épuise le budget puis produit une absence.

Le bloc intact est pixel-identique avec/sans poche et avec/sans source Bone.
Même absence d’indice sur les quatre couvertures et après ouverture locale.
La lumière uniforme, les ombres des seuls os exposés et le correctif du contour
orange passent les contrôles natifs. Picking, champs Bone, F6/F7, outils, Brush,
dégâts et préparation complète 100/100 restent couverts par les régressions.
La source B-17 conserve le SHA256
`942bfde8c127b3ed4055884295817e48fefd233d360debd7d90614cc6df2f346`.

Physique 60 Hz / cap 240 conservés. Aucun débit soutenu de 240 FPS n’est déduit de
ces captures ou de ces tests. Le checkout principal et ses changements existants
sont préservés ; tout le travail se trouve dans le worktree attaché.

### Reproduire

Avec Godot 4.7.2 stable, `--path . --script tests/run_p6a49_pocket_finish.gd` :

- logique : `--headless`, puis arguments utilisateur
  `-- tests --distinction-store=res://work/test-logs/p6a49/distinction-tests.json` ;
- rendu natif : sans headless, puis
  `-- visual --distinction-store=res://work/test-logs/p6a49/distinction-visual.json` ;
- effets natifs : sans headless, puis
  `-- motion --distinction-store=res://work/test-logs/p6a49/distinction-motion.json`.

Les fichiers de distinction QA sont séparés de la collection du joueur.

## Prise en main et limites

`Launch-Game.ps1` ouvre la scène `scenes/p6a49_pocket_finish.tscn`.
Fouiller normalement au Chisel (2), souffler (3) sur les grains découverts, puis
reprendre Pick (4) / Brush (1) selon la matière. H ouvre le panneau :
« Nouvelle préparation · recommencer » passe au cas suivant et remet le bloc à
zéro. R rejoue exactement le cas choisi. Le quatrième cas n’a aucune poche.

La recette peut servir aux futurs spécimens après configuration de leurs zones
admissibles. Cette livraison conserve cinq graines de revue ; elle ne constitue
pas le générateur de toute la collection. La probabilité de recette 0.8 reste un
paramètre d’essai, pas une fréquence de production validée. Le volume utilise
la hauteur excavable actuelle : pas de tunnel ni de surplomb persistant sous une
couverture épaisse. La plaque/levier P6A46 n’est pas réintroduite.

Pour clôturer humainement : repérer les grains sans aide répétée, passer au souffle
avec un résultat franc, identifier le retour au fond compact et reprendre le
Pick sans poursuivre de restes invisibles. Puis figer cette référence si Antoine
la valide, et avancer vers la mission suivante.

## Livraison GitHub

Source du candidat : `2546e74`, branche `codex/p6a49-pocket-finish`.
[PR #23 DRAFT](https://github.com/ezzerx/archaeology-game/pull/23), basée sur main ;
#22 remplacée sans fusion, branche et preuves précédentes conservées.
Dossier local : `C:\Users\antoi\.codex\worktrees\p6a32-fossil-mesh\ArchaeologyGame`.
`Launch-Game.ps1` ouvre « ArchaeologyGame — B-17 · Poches friables » sous Godot
4.7.2. Lancement vérifié : fenêtre native répondante, sortie moteur attendue,
aucune erreur stderr. La nouvelle fenêtre garde un bloc initial à découvrir ;
les anciennes sessions utilisateur sont conservées.

## Retour humain — 2026-10-15 : référence validée, finition ultérieure différée

Antoine valide explicitement le résultat actuel. La poche friable peut servir
de référence de travail ; une nouvelle passe de finition pourra être envisagée
plus tard lorsque d’autres systèmes interagiront avec elle. Clore cette itération
plutôt que poursuivre des corrections isolées. Ce retour ne définit pas la
fréquence de production ni le générateur global de la collection. Antoine demande
ensuite une recommandation sur le prochain chantier au plus fort levier ; la
sélection de ce chantier reste distincte de la présente validation.
