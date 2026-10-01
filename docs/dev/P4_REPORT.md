# Rapport P4 — Game Feel / Material Reactions

**2026-10-02 · `prototype/p4-game-feel` · Godot 4.7.2 stable Standard / Compatibility.**

P4 est implémenté et testé automatiquement. [PR #5](https://github.com/ezzerx/archaeology-game/pull/5), commit d'implémentation `42ec46d`. **Validation humaine attendue, PR non mergée, P5 interdit.** Source de vérité : [P4_BRIEF](P4_BRIEF.md).

## Comportement livré

| Matière / outil | Réaction |
|---|---|
| Soil + Brush | Retrait continu, grains légers, frottement granulaire modulé par retrait et mouvement |
| Clay + Brush | Faible efficacité historique, son de raclement ; aucun bonus près des os |
| Clay + Chisel | Marques persistantes → seuil de stress → plaque angulaire, retrait discret et éclats plats |
| Sandstone + Chisel | Cellules plus petites, seuil plus dur, fissures → petits fragments, son sec et résonant |
| Air Blower | Nettoyage du résidu P2, poussière entraînée et souffle ; hauteur strictement inchangée |
| Contact Bone | « tik » fin, anneau ivoire bref, notification P3 ; −3 points uniquement si le centre était déjà exposé |

Trois outils en géométrie placeholder suivent le hit réel ; Brush oscille légèrement pendant le travail, Chisel recule à chaque impact valide, Blower présente une buse. Sans mains, colliders ni animation autoritaire. Le marqueur précis reste visible mais plus discret en vue normale.

La lumière principale est légèrement réchauffée, le voile de poussière devient terreux et moins masquant sur l'os. La palette des couches et de l'os reste celle du prototype ; aucun Art Pass, décor, progression, objectif, classification ou sauvegarde ajouté.

## Fracture et effets

[Décision complète](P4_MATERIAL_REACTION_DECISION.md).

- Partition angulaire déterministe, seed 417 ; cellules Clay 9 texels / Sandstone 5 texels. Au centre, en matériau homogène, les valeurs par défaut cassent Clay au deuxième impact, Sandstone au troisième. Le falloff règle l'accumulation de stress, pas la forme lissée du retrait.
- Seuils 0,12 / 0,13 unités de travail normalisées ; profondeurs 0,15 / 0,08. Chaque cellule reste dans la couche touchée au début de l'impact, puis est clippée au plafond osseux. Aucun tunneling.
- Stress sparse et atlas RG8 **242×133 = 64 372 octets**, mis à jour seulement sur changement. Aucun parcours full-map par frame ; géométrie RF et picking DDA conservés.
- Quatre pools MultiMesh de 48 éléments, **192 débris maximum**, durée par défaut 0,42–0,78 s. Petit rebond visuel sur la hauteur d'émission, sans physique gameplay. La poussière authoritative reste le résidu P2 ; aucun débris ne peut creuser, protéger ou endommager.
- Six familles de sons × quatre variantes, PCM mono 22 050 Hz généré au lancement. Pitch ±4 %, volume ±1 dB ; pool de huit voix, débit limité pour les gestes continus, impacts liés à la cadence réelle. Aucun asset externe ni licence à clarifier.
- Reset : hauteur, résidu fin/R8, stress/atlas, événements, particules, recoil, audio et RNG visuel restaurés. En F2, les effets sont masqués pour lire les données sans occlusion.

Les paramètres sont dans `config/material_reactions.tres`. Les valeurs des trois outils historiques restent inchangées. L'estimation de vitesse dans F1 est explicitement celle du noyau avant fracture ; le temps réel dépend maintenant des plaques et du stress.

## Bone Condition : résultat et limite

**Aucune marge de 2 mm, aucun Brush spécial près des os, aucun arrêt automatique du Chisel.** Les règles P3 sont conservées.

La [sonde reproductible](evidence/p4-condition.json) brosse la zone supérieure du crâne puis frappe une grille locale. Elle évite les centres déjà visibles, sans consulter les plafonds osseux cachés pour choisir les coups. Résultat : **1 004 impacts**, soit **223,11 s de Chisel théoriques**, **4 105 cellules osseuses révélées**, **49,87 % du crâne / 12,71 % du spécimen**, condition **100 %**. Les dix coups suivants volontairement centrés sur un os exposé donnent **100 → 70 %**.

C'est une preuve que la révélation d'une région significative sans dégâts est possible. **La sonde reconnaît les texels visibles parfaitement et réagit sans délai ; elle ne prouve pas que le joueur y arrive naturellement.** Elle ne mesure pas non plus un temps de session humain, qui comprend visée, pauses et changements d'outils.

Le benchmark de maintien près de l'os, sans précaution, expose 404 cellules et termine à **25 % après 27 impacts**. La perte provient des centres déjà exposés, même si du matériau reste dans le bord du footprint. Cette règle peut encore sembler exigeante sur les petites traces ivoire. **Si le test humain juge ce geste inévitable ou illisible, arrêter pour revue du cas précis avant d'ajouter une protection.** Le tuning final reste P7.

## Vérifications

**495 checks fonctionnels, zéro échec :** P0 45, P1 52, P2 97, P3 85, zoom/input 160, P4 56. Les suites historiques et leurs seuils n'ont pas été modifiés.

Les tests P4 couvrent déterminisme de hauteur/stress/résidu, changement de seed, Clay ≠ Sandstone, phase de marques sans retrait, profondeur de plaque discrète, absence de bridge, footprint et interfaces, plafond osseux, premier contact, dégâts une fois par impact, outils sûrs, Blower sans hauteur, invalides sans événements, reset exact, routage réel Soil/Blower, six banques audio non silencieuses/sans clipping et présence des proxies. **225 rayons supplémentaires** passent sur des arêtes fracturées.

Les tests P0–P3 numériques continuent à isoler le noyau historique lorsqu'ils construisent une `WorkingSurface` sans profil. La **scène normale active P4**, ce que la nouvelle suite vérifie explicitement. La suite de zoom conserve ses **4 432 rayons**, ses quatre tailles de fenêtre et toutes les commandes P3.

L'oracle graphique P3 passe sur **194 955 pixels à 1×/2×/3×**, textures GPU/CPU identiques, huit cas de frontière résolus selon la tolérance historique de 0,01 texel. Erreur de hauteur normalisée maximale **0,004826**, sous le seuil existant 0,01 ; erreur de couleur corrigée maximale **0,010883**, sous 0,02. Les proxies sont masqués dans les vues de données, pas dans les scénarios de jeu mesurés.

Commande complète :

```powershell
& tests/check_p4.ps1 -GodotBin 'C:\Users\antoi\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' -Graphical
```

Logs locaux dans `work/test-logs/`. Preuves : [benchmark P4](evidence/p4-benchmark.json), [oracle GPU P3 sur P4](evidence/p3-on-p4-gpu.json), [condition](evidence/p4-condition.json).

## Performances

RTX 5080 / Ryzen 7 9800X3D, 1920×1080, Compatibility, **cap 240 FPS et physique 60 Hz**, VSync désactivée uniquement dans le benchmark. Dix scénarios de six secondes ; préparation, warmup et captures hors timing. Effets actifs, périphérique audio réel avec bus muet pendant les mesures.

| Scénario | FPS 1× / 3× | Frame P95 1× / 3×, ms | CPU édition active moyen 1× / 3×, ms |
|---|---:|---:|---:|
| Soil Brush | 239,70 / 239,69 | 8,842 / 8,807 | 4,260 / 4,247 |
| Clay fracture | 239,87 / 239,87 | 4,293 / 4,290 | 1,245 / 1,251 |
| Sandstone fracture | 239,87 / 239,87 | 4,298 / 4,297 | 1,098 / 1,074 |
| Chisel près de Bone | 239,87 / 239,87 | 4,289 / 4,298 | 0,977 / 0,960 |
| Blower + dust | 239,86 / 239,86 | 4,530 / 4,527 | 0,188 / 0,186 |

Maximum final : **11,597 ms**. Tous passent le budget historique (≥58 FPS, P95 <20 ms), sans réduire le cap ou la densité du terrain. Blower : zéro upload de hauteur. Clay : 28 plaques / 27 impacts ; Sandstone : 9 fragments / 27 impacts sur le parcours mesuré. Les statistiques incluent réellement les effets, les sons déclenchés et les ruptures.

Un premier passage avec le driver audio Dummy a observé une frame isolée de **583,578 ms au premier effet**, compatible avec la compilation du matériau instancié. Une instance subpixel sous le bloc pendant deux frames préchauffe maintenant cette variante au démarrage. Le second passage avec WASAPI n'a pas reproduit le pic ; le cache étant déjà chaud, **la disparition sur un nouveau pilote n'est pas garantie**. Aucun chantier de grille ou optimisation GPU générale engagé. Un premier démarrage graphique est également resté bloqué avant rendu ; relance puis démarrage normal avec WASAPI réussis, cause non établie.

## Captures contrôlées

Les cavités rectangulaires des comparaisons sont des **fixtures de benchmark**, pas le terrain initial du joueur.

- [Clay : marque](evidence/p4-clay-mark.png) → [plaque détachée](evidence/p4-clay-chip.png)
- [Sandstone : fissure](evidence/p4-stone-mark.png) → [fragment détaché](evidence/p4-stone-chip.png)
- [Contact Bone à 3×](evidence/p4-bone-3x.png)

## Test humain — 3–5 minutes

Ouvrir `project.godot`, lancer F5, masquer les panneaux avec F1. Partir du bloc intact, sans modifier les réglages debug. L'écoute réelle et le plaisir restent à valider humainement.

1. **Soil** : brosser en bougeant pendant 30–45 s. Juger continuité, grains, frottement et présence du pinceau.
2. **Clay** : passer au Chisel avec 2, puis un nouveau clic. Faire quelques frappes isolées, puis maintenir. Observer marque → plaque ; comparer au pinceau presque inefficace.
3. **Sandstone** : poursuivre la même petite cavité. Juger s'il exige davantage d'impacts et produit un son et des fragments distincts. Essayer à 1× puis 3× avec la molette.
4. **Dust / découverte** : utiliser 3 et souffler. Juger si le nettoyage rend le fond et l'os plus lisibles. Au « tik » / Bone detected, relâcher et changer d'outil. Pour retrouver le crâne rapidement : zone supérieure gauche du bloc, sans affichage d'une silhouette cachée.
5. **Condition** : continuer à côté des os visibles, puis consulter F1. Dire si les pertes correspondent à un coup risqué compris ou si le geste impose encore une punition. R remet tout à zéro, Home restaure la vue ; commandes debug P3 inchangées.
6. **Verdict** : Soil/Clay/Sandstone se distinguent-ils par le geste ? Le Chisel casse-t-il plutôt qu'il n'efface ? Le changement d'outil paraît-il naturel ? Bone detected se remarque-t-il ? La condition paraît-elle plus juste ? Est-ce simplement plus amusant pendant ces quelques minutes ?

Ne pas considérer cette liste comme validée avant le retour d'Antoine. **Arrêt à P4, aucun merge automatique ni démarrage de P5.**
