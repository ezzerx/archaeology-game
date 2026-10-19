# Preuves de la V1 des arrivages

- `arrivals-headless.json` : 75 contrôles réception et cadrage.
- `workshop.json` : 22 contrôles du retour depuis l’atelier.
- `storage.json` : 18 contrôles d’archivage existants.
- `windows-build.json` : moteur, commit runtime et SHA-256 du ZIP Windows.
- `pack-smoke.txt` : chargement du paquet isolé, sources exclues.
- PNG : vues natives OpenGL logiciel, 1280 × 720. Vue générale, focus fermé,
  puis ouverture avec cadrage corrigé. Le rendu Forward+ du build reste à
  valider sur PC ; aucune mesure de FPS matériel n’est déduite du cloud.

La vue générale et le focus fermé précèdent le correctif limité à la caméra
pendant l’ouverture ; ces deux états fermés sont inchangés. La capture ouverte
correspond au runtime `35b921e`.
