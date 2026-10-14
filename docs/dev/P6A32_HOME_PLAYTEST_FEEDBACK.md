# Retour humain natif — 2026-10-13

Retour d’Antoine sur le candidat combiné P6A3.1/P6A3.2, lancé avec Godot 4.7.2 stable sur le PC de référence. Discussion de conception en cours ; aucun GO d’implémentation des propositions suivantes.

## Observations et préférences confirmées

- Antoine préfère le style du squelette précédent, jugé plus cohérent avec le thème. La capture fournie sert de référence de style ; la comparaison effective du crâne Tripo est non concluante à cause du conflit F6/F7.
- La dégradation visible et la jauge Condition améliorent la lecture. Des fissures orientées de façon répétitive et une dégradation partout simultanément ne conviennent pas.
- Antoine a atteint 100 %. Il souhaite que cet accomplissement soit récompensé ; forme de récompense à définir.
- Poussière du Brush trop peu visible. Nettoyage des os trop long, feedback tactile insuffisant ; le joueur agite la brosse pour gagner les derniers pourcentages. Il souhaite une action plus directe et une durée justifiée par des traces visibles.
- F6 réduit le cercle et F7 l’agrandit, contrairement aux indications du comparatif.

## Diagnostic de lecture du code

`ToolController._unhandled_input` consomme F6/F7 pour le tuning debug avant les comparatifs hérités. Le rayon réel peut donc avoir été modifié pendant ce test ; la préférence de style reste valable, mais un A/B contrôlé et une mesure de nettoyage nécessiteront une nouvelle session avec les raccourcis corrigés.

B-17 est une anatomie explicitement dessinée en code dans `FossilField`, via des segments arrondis et hauteurs, puis rendue par la surface de relief. Ce n’est pas un générateur de nouveaux animaux autonomes. La viabilité d’une famille d’assets paramétriques est une proposition, pas une architecture approuvée.

P6A3.1 conserve la vitesse de nettoyage précédente et renforce visuellement le Film résiduel. Les fissures sont un motif de shader consommant la Condition globale, sans localisation des impacts. Ces choix expliquent des limites de représentation ; ils ne constituent pas une mesure de durée du test humain.

## Pistes à discuter, non autorisées à implémenter

- Conserver le rendu précédent comme référence de style ; évaluer ultérieurement des os paramétriques et spécimens composés, avant toute généralisation du pipeline.
- Réserver sans ambiguïté les touches de comparaison et indiquer leur état courant ; préserver les réglages de référence pour le retest.
- Localiser les marques sur les vrais impacts dommageables, avec directions variées ; conserver une seule autorité Condition, sans ajouter implicitement destruction, réparation ou nouveau système de dégâts.
- Nettoyage à réponse immédiate : passes courtes et lisibles, traces résiduelles honnêtes, poussière perceptible et proportionnelle au retrait réel. Le périmètre autorisé des presets partagés reste inchangé tant que la correction n’a pas été convenue.
- Distinction de préparation à 100/100, indépendante d’une éventuelle distinction de conservation. Aucun mode, bonus économique ou changement d’Archive encore décidé.

Prochaine étape : clarifier avec Antoine le comportement de nettoyage et la récompense, puis convenir d’un périmètre de correction avant action. Aucun merge #10/#11, extension de production, Sound/Light ou P6B automatique.
