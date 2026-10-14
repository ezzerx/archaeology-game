# P6A3.8 — Essai de lampe orientable

GO Antoine le 2026-10-14 : lampe orientable, ambiance chaude, interactions
validées conservées, aucun os enterré révélé. Référence main ff3ffd7 / B-17 P6A3.7.

Manipulation bornée autour du bloc : la vraie source se déplace pour changer le
sens des ombres. Conserver température/couleur, puissance, ouverture du faisceau,
bounce et éclairage d’ambiance acceptés. Reprendre l’objet de lampe existant.
La pose initiale doit rester exactement celle de la référence.

Entrée simple : L ou bouton Lampe, glisser gauche/droite, L/Échap pour revenir
aux outils. Reset de lampe distinct du reset de spécimen. Préserver zoom, pan,
inspection et raccourcis existants ; aucun geste de lampe ne peut armer un outil.
Annuler une capture au changement de focus, sortie souris, redimensionnement,
mode d’inspection ou changement de comparaison d’éclairage.

Scène et lanceur isolés, aucun changement du lancement de main. Garder le shader
masqué et le caster des seules cellules dégagées. Vérifier chaque orientation sur
matrice intacte et révélation partielle, y compris silhouette/ombres avec modèle
on/off, indices réellement soumis, reset et contacts. Vérifier invariance complète
de la préparation et des presets pendant la manipulation réelle souris/clavier.
Captures natives et mesures courtes, puis verdict humain sur l’utilité pour lire
le relief. La gate reste dans docs/brain/status.md ; ni nouveau contenu ni audio.
