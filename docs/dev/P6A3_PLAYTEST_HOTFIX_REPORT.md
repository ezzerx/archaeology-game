# P6A3 — Playtest hotfix, 8 octobre 2026

Correction ciblée demandée après test humain. Le statut du dépôt conserve la gate.

- Les quatre modèles P6A3 restent, mais leur placement au hit et leur redressement
  adaptatif sont retirés du chemin actif. Ancrage caméra à 86 % de la largeur,
  80 % de la hauteur ; taille de présentation constante (environ 150 px),
  indépendante du zoom et du relief. Le plan est devant la matrice, sans collider.
- Brush garde son petit sweep, Chisel son recoil court, Pick son jab et Blower
  sa légère contraction. Déplacement d'animation borné sous 10 px ; aucun suivi
  du curseur ni dérive sur le relief. Le curseur natif continue de désigner le
  vrai point d'action. Visibilité conditionnée au survol valide comme auparavant.
- Retour direct à `MaterialAudio`, le composant P4/P5/P6A2. Aucun nouveau son,
  retuning ni tentative de sauver les Foley P6A3. Sources historiques conservées.
- VFX, matériaux, lampe, UI, règles, caméra interactive et assets inchangés.

## Limite Chisel

La mission mentionne des images jointes, dont la dernière doit définir le setting
du Chisel, mais aucune image n'est attachée à ce message reçu. La capture antérieure
de PowerShell et l'ancienne double lame Tripo ne constituent pas cette référence.
Le mesh corrigé à lame unique est conservé. **Correspondance au setting demandé
non vérifiée ; référence à renvoyer.** Ne pas présenter ce point comme terminé.

## Vérification

Godot 4.7.2 : 75 contrôles, zéro échec. Brush Soil, Brush Clay, Chisel Clay,
Chisel Sandstone, Pick matrice/proche Bone, Blower débris, Brush Film : états
gameplay identiques au témoin, animations présentes, ancrage borné et ancien
composant audio chargé. 24 captures, zéro erreur de capture/script.

Deux différences initiales de hash ont identifié une dépendance du banc au zoom
encore interpolé par les frames de rendu. Le banc arrête cette interpolation après
son cadrage et fixe la taille exacte ; aucun code caméra de gameplay n'est changé.
Les trajectoires comparées conservent leurs contrôles d'égalité stricte.

Preuves : `evidence/p6a3-hotfix/tests.json`, `visual.json`, captures Brush/Chisel.
Le package Windows est reconstruit avec `tools/p6a3/Export-Playtest.ps1`.
Exécutable autonome testé : PACKED ART PASS, outils natifs/reset PASS, sortie 0.
Empreintes du package dans `evidence/p6a3-hotfix/package.json`.

## Retest

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Launch-P6A3-Tool-Feel.ps1
```

Alt+Entrée : plein écran. Ou `builds/P6A3-Playtest/ArchaeologyGame.exe`.
Tester les six interactions, déplacer le curseur, zoomer : le modèle reste ancré
en bas à droite ; seuls les petits gestes d'action bougent. F12 reste le témoin
historique P6A2, qui conserve son ancien placement au curseur ; revenir en P6A3
pour tester le hotfix. Validation humaine requise avant de qualifier le playtest.
