# Preuves de la passe musée

Images natives Godot 4.7.2 / RTX 5080. `before-study.png` et
`after-study.png` montrent les mêmes fixtures explicites (1600×900) ;
`real-*.png` montrent des copies des vraies préparations (1920×1080).
Aucune archive joueur n’est publiée. Le cadrage général a été ajusté.

Les JSON conservent mesures et contrôles. Les deux fichiers
`historical-replay-*.json` sont volontairement des échecs du vieux protocole :
voir `../../MUSEUM_REPLAY_DIAGNOSTIC.md`. `replay-headless-exact.json`
porte la comparaison corrigée à caméra contrôlée ; `replay-native-exact.json`
confirme le même test en Compatibility natif.

`handoff-smoke.gd` conserve le harness natif, à copier sous `work/` pour
reproduction. Il appelle les vrais handlers sur une collection QA déjà copiée,
sans archiver de nouvelle préparation. Les processus enfants sont contrôlés
puis fermés par le pilote de test.

La référence artistique reste la pièce jointe de la demande ; elle n’est pas
redistribuée dans le dépôt. Ces preuves ne valent pas validation humaine.
