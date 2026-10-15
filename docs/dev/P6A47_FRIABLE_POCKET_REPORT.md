# P6A4.7 — Poche friable : contrat de l’essai

GO explicite d’Antoine le 2026-10-15 : réaliser une première proposition convaincante,
avec une approche de game design, pour tester une autre source de rejouabilité.

## Intention

Faire varier le geste, pas la durée : reconnaître une croûte poreuse, l’ouvrir en
quelques coups, puis évacuer une lentille de grains au souffleur. Le résultat doit
être immédiatement visible : front qui recule, grains entraînés et cavité réelle.
Le souffleur devient pertinent localement ; il ne creuse toujours pas la matrice solide.

## Contrat de la première proposition

- Une seule lentille irrégulière, située sur le cou et le départ des côtes de B-17 ; aucun puzzle
  de points secrets ni obligation d’ouvrir tout le périmètre.
- Croûte d’argile mince, érodée et ponctuée de grains : transition diffuse, sans
  contour de plaque ni pièce ajoutée par-dessus le terrain.
- Une petite ouverture suffit à amorcer le soufflage. Les balayages courts
  évacuent les grains accessibles et déchaussent progressivement la croûte proche.
  Souffler sur une croûte intacte ou ailleurs n’excave rien.
- Le Chisel reste une solution plus grossière ; pas de pénalité artificielle,
  outil supplémentaire, jauge, minuterie ou blocage de la session.
- Vide final irrégulier calculé dans la vraie hauteur, sans retrait automatique
  de tout le volume. Les os restent sous leur couverture réelle.
- Outils, Brush, dégâts localisés, collection, lumière uniforme chaude et modèle
  B-17 conservés. La plaque précédente reste dans sa scène historique.
- R restaure exactement la situation ; aucun calcul de poche à l’arrêt.

## Critères de revue humaine

Comprendre l’intérêt du souffleur dès le premier essai, obtenir un changement
franc en quelques balayages et avoir envie de retrouver ce comportement dans
un autre bloc. Les preuves automatiques ne valident ni le plaisir ni l’art final.

## Livraison et preuves

Scène : `scenes/p6a47_friable_pocket.tscn`. Entrée : `Launch-Game.ps1`.
La zone mouchetée se situe sur le cou et le départ des côtes, au centre du bloc.
Chisel (2) ouvre la croûte ; Blower (3), maintenu avec de courts allers-retours,
évacue les grains. Pick (4) reprend ensuite le travail de matrice ; Brush (1)
conserve son nettoyage validé. R restaure la préparation.

### Construction et rythme

Une même inclusion façonnée définit le cap poreux, la couleur des grains et le
fond du creux : pas de plaque ajoutée ni contour uniformément peint. Le cap
réel réduit localement la couverture superficielle, avec une transition diffuse.
L’inclusion traverse 4 386 cellules Bone du trajet de préparation, tout en les
laissant couvertes. Le fond varie d’environ 1.3 à 22.5 mm sous le toit granulaire.

Le parcours témoin ouvre la poche en **un impact** et évacue **82.6 % du volume
granulaire en trois balayages de 0.70 s**. Plusieurs autres prises s’ouvrent en
au plus trois impacts. Ces chiffres cadrent le premier essai ; ils ne constituent
ni un équilibre final ni une promesse identique pour tous les gestes.

Chaque souffle retire la vraie hauteur, uniquement dans sa zone d’action. Les
grains soutenant la croûte voisine doivent avoir reculé avant que celle-ci puisse
s’effriter dans le jet. Le front utilise des sous-pas fixes et une éligibilité
figée au début du pas, ce qui évite un retrait instantané dépendant de l’ordre
d’itération. Un souffle immobile travaille localement ; un balayage atteint les
extrémités. La voie Chisel reste possible sans pénalité ajoutée.

Les grains animés prennent leur origine dans la matière réellement retirée.
Particules et poussière restent plafonnées ; aucun corps physique par grain.
Le vieux son d’air est réutilisé. Les marques de fracture de la croûte retirée
ne sont pas réimprimées sur le nouveau fond compact.

### Protection des interactions

Un petit point d’extension de retrait, neutre dans `WorkingSurface`, permet à
cette seule scène d’arrêter le premier impact au toit granulaire. Les ressources
des outils, leur cadence et leurs paramètres restent ceux de la référence.
Le Blower conserve puissance zéro et efficacité solide zéro hors de l’inclusion.

Le fond utilise une borne conservatrice commune de couverture et un relief
façonné indépendant de l’anatomie ; il n’imprime pas les contours des os enterrés.
Le soufflage n’émet ni exposition Bone, ni dégâts, ni progression de collection.
Un court travail natif au Pick peut ensuite révéler réellement les os. Les
comparaisons de modèle, le reset et le nettoyage restent ceux de B-17.

### Preuves conservées

**442 contrôles, zéro échec** : candidat 136, rendu natif 35, P1 52, P5 128,
miettes P4V2 91. Les 30/60/120 Hz d’appel donnent la même excavation stationnaire.
Le circuit souris réel, le relâchement, la perte de focus, le reset exact et
l’absence de calcul/actualisation de poche au repos sont vérifiés.

Comparaisons natives sur RTX 5080 : aucune différence de pixels avec le modèle
caché sous croûte intacte ou poche évacuée. Les ombres des os réellement exposés,
l’équilibre lumineux, le contour orange corrigé et le squelette complet sont
retestés. Source B-17 inchangée : SHA256
`942bfde8c127b3ed4055884295817e48fefd233d360debd7d90614cc6df2f346`.

Données et cinq captures : `docs/dev/evidence/p6a47/`.
Commandes : Godot 4.7.2 stable, script `tests/run_p6a47_friable_pocket.gd`,
mode normal headless et `-- visual` avec rendu natif ; régressions `run_p1_tests`,
`run_p5_tests`, `run_p4v2_tests`. Cap 240 / physique 60 Hz conservés. Le coût
ponctuel de souffle varie dans ce harnais ; aucune performance soutenue à
240 FPS n’est déduite de ces contrôles.

### Limites de l’essai

Une seule inclusion façonnée, sans aléatoire ni simulation volumétrique générale.
Le retrait reste une surface de hauteur : pas de tunnels ni surplombs persistants.
La plaque reste conservée dans sa scène historique. La lisibilité et le plaisir
attendent le test humain ; aucun verdict définitif ou merge n’est déduit.

