# P6A2 — Soil & Playtest Presentation : preuves

Captures GPU Godot réelles, réencodées en JPEG sans retouche. Même scène B-17, caméra et éclairage pour les comparaisons Soil ; les images A/B partagent le nouveau restyle et les accessoires pour isoler la matière. Les fichiers `*-before*` utilisent l’ancienne couverture, `*-after*` la nouvelle. Le témoin UI historique se trouve dans [la livraison précédente](../p6a2-correction/hero-reset.jpg).

| Comparaison | Avant | Après |
|---|---|---|
| Soil à 1× | [ancien profil](soil-before-1x.jpg) | [amas fragmentés](soil-after-1x.jpg) |
| Soil à 3× | [ancien profil](soil-before-3x.jpg) | [amas fragmentés](soil-after-3x.jpg) |
| Couverture isolée, patine OFF | [ancienne](soil-before-no-patina.jpg) | [nouvelle](soil-after-no-patina.jpg) |

Progression : [brossage partiel natif](soil-part-brushed.jpg), [substrat dégagé](soil-cleared.jpg), [Bone préparé par outils natifs](bone-prepared.jpg).

UI : [objectif atteint](ready-to-archive.jpg), [poursuite choisie](keep-cleaning.jpg), [archive](archive.jpg). Ces trois états emploient les fixtures P5 pour vérifier l’UI et les transitions ; ils ne sont pas présentés comme une session humaine enregistrée.

Affichage : [1280×720](display-1280x720.jpg), [1920×1080](display-1920x1080.jpg), [2560×1440](display-2560x1440.jpg), [fenêtre 16:10](display-1600x1000.jpg), [plein écran natif](display-native-fullscreen.jpg). Le contenu conserve le cadrage 16:9 et les autres rapports reçoivent des bandes, sans coupe de l’aire de jeu.

Références de lecture : [01 gameplay](../../../visual-references/p6a2/01-gameplay-target.jpg) / [02 matière](../../../visual-references/p6a2/02-material-closeup.jpg). Le Soil se fragmente en vrais dépôts, son grain vient de la source v02 et les interstices découvrent Clay. La lecture reste moins volumétrique et artisanale que le concept ; les images ne prouvent pas le plaisir de brosser.

Mesures : [morphologie et invariants](tests.json), [captures](visual.json), [affichage/picking](display.json), [performance](benchmark.json), [règles P5](p5-regression.json). Le rapport explique les comparaisons et leurs limites.

Livraison : [performance en plein écran natif](benchmark-native.json), [empreintes du ZIP](export-package.json), [exécution du ZIP décompressé](export-smoke.txt), [capture issue du binaire release](export-release.png).
