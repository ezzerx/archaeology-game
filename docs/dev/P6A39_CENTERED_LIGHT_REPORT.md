# P6A3.9 — Lumière fixe centrée

Demande Antoine du 2026-10-14 : mettre la lampe au centre pour éclairer le bloc de
façon plus uniforme, après abandon de la manipulation mobile. Reprise depuis
main ff3ffd7 ; code du candidat mobile non intégré.

## Périmètre

Lampe existante fixée au milieu du bord arrière, source tournée vers le centre,
bounce et faible fill alignés sur le même axe. Conserver couleur chaude,
puissance, ouverture et ombres des seuls os exposés. B-17, outils, matériaux,
contacts, Brush et dégâts localisés restent inchangés. Scène historique P6A3.7
conservée ; le lancement normal ouvre le candidat centré pour revue.

## Clarification humaine — contours orange

Antoine confirme que les restes se retirent bien. Son retour porte sur leur
aspect artificiel : l’argile semble adhérer et dessiner le contour des os.
La capture zoomée confirme ce motif visuel. Ne plus traiter le signalement comme
un blocage d’outil. Le retrait possible ne valide pas la qualité artistique.
Aucun changement du contour, des matériaux ou des règles n’est fait dans cette
passe de lumière ; garder ce défaut visible comme point de reprise spécifique.

## Suite proposée

Blocs aux silhouettes naturelles : bords cassés, pans asymétriques, épaisseur
variable ; préserver zones utiles, absence de Bone enterré visible et picking.
Un petit essai du bloc actuel suffit avant un lot de blocs. La forme extérieure
ne corrige pas à elle seule les restes qui dessinent les os. Aucun nouveau
matériau, outil, catalogue ou Sound Design dans cette passe.

## Vérification

**107 contrôles, zéro échec** : 90 headless (85 hérités de B-17, 5 ciblés),
17 graphiques natifs, RTX 5080 / Compatibility / Godot 4.7.2. Preuves JSON et
sept captures dans `docs/dev/evidence/p6a39/`.

- Matrice intacte : viewport entier pixel-identique avec source retirée et aucun
  caster Bone. Révélation partielle : régions de mâchoire, vertèbre, côte et patte
  réellement enterrées pixel-identiques avec source retirée ; indices du caster
  partiel conservés. Les contrôles hérités vérifient l’ensemble des cellules
  soumises, les contacts, le nettoyage, les dégâts, le reset et la complétion.
- Témoin neutre horizontal mat à hauteur du bloc : six patches de 25 pixels,
  trois paires x = ±.42 m et z = -.22 / 0 / .22 m. Écart moyen relatif gauche/droite
  **23.99 % avant, 0 % après** à ces points ; luminance .2344 de chaque côté,
  sans saturation. Cela prouve l’équilibre latéral du témoin, pas un éclairement
  identique de chaque face du relief ou une absence de variation avant/arrière.
- Sur B-17 dégagé au vrai Pick et nettoyé par le helper QA, les ombres du caster
  exposé assombrissent encore 20 784 pixels de la région contrôlée de plus de .025.
  Comparaisons graphiques sans modification d’état de préparation.
- Température, puissance et ouverture conservées ; pas de nouvelle lumière,
  de contrôleur mobile, de mesh d’os ni de règles de fouille. Cap 240 / physique 60
  conservés, sans nouvelle mesure soutenue isolée.

Deux corrections du harnais avant la réussite finale : comparer les propriétés
flottantes avec tolérance, puis flusher la session après le nettoyage QA avant
la prise d’empreinte. Le témoin initial trop clair a été abaissé et un contrôle
anti-saturation ajouté. Aucun changement runtime nécessaire pour ces corrections.
La qualité artistique et le confort de lumière restent à juger humainement.


## Livraison de revue

Branche `codex/p6a39-centered-light`, source `6532f35`,
[PR #13 DRAFT](https://github.com/ezzerx/archaeology-game/pull/13) basée sur main.
`Launch-Game.ps1` a ouvert une nouvelle fenêtre Godot 4.7.2 / Compatibility,
titrée B-17 · Lumière centrée, répondante et sans erreur stderr. Les sessions
précédentes n’ont pas été fermées ou réinitialisées. Aucun merge effectué.
