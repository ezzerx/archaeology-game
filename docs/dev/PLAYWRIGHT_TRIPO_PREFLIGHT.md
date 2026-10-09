# Playwright / Tripo Studio — test du 8 octobre 2026

## Résultat

**Installation et test d'accès/export réussis, avec réserves de fluidité.**
Test limité à la lampe existante `f32be606-c368-40ad-9de7-92d58af179b9`.
Solde affiché avant/après : **25 070 / 25 070 crédits**. Aucun lancement de
génération, retopologie, texture ou autre traitement payant.
La gate de reprise du jeu reste définie uniquement par `docs/brain/status.md`.

## Installation locale

- Serveur officiel Microsoft `@playwright/mcp` **0.0.83**, version fixée.
- Dépendance Playwright fournie par ce package : `1.64.0-alpha-1790635538000`.
- Extension officielle Microsoft **0.4.0**, ajoutée par Antoine dans Chrome.
- Node **24.18.0** ; Chrome **154.0.8037.98**.
- Installation : `%LOCALAPPDATA%\Programs\ArchaeologyGameTools\playwright-mcp`.
- Configuration MCP `playwright` ajoutée à `C:\Users\antoi\.codex\config.toml` :
  Node lance `node_modules\@playwright\mcp\cli.js --extension --browser chrome`.
- Configuration précédente sauvegardée dans `.codex/config.before-playwright.20261008-175831.toml`.
  Tous les champs précédents sont préservés ; seul le serveur Playwright est ajouté.
- Aucun binaire, module npm ou identifiant de session ajouté au Git du projet.
- Test de protocole effectué via le client MCP officiel `@modelcontextprotocol/sdk`
  **1.29.0** : initialisation, liste des outils, connexion à l'onglet Chrome autorisé.
  La configuration Codex est persistante ; l'exposition native de ce nouveau serveur
  dans une prochaine session dépend du rechargement des serveurs MCP par le client.

## Preuves sur Studio

- Session Studio connectée réutilisée ; historique personnel et solde lisibles.
- Ouverture de la lampe, aperçu 3D, paramètres d'export GLB / textures 2K lisibles.
- Export téléchargé par Chrome : `archeo_lamp_playwright_probe.glb`.
- Fichier GLB 2 valide : **62 225 492 octets**, 1 940 580 triangles,
  un mesh, un matériau, trois images incorporées. Master uniquement.
- Payload géométrie/textures **identique** à celui du master déjà récupéré ;
  le changement du nom d'export explique le fichier JSON/conteneur différent.
- Copie de contrôle : `work/playwright-test/lamp-master-probe.glb`.
- Validation/chiffres : `work/playwright-test/result.json` ; capture :
  `work/playwright-test/studio-lamp.png`. Ces fichiers de test sont ignorés par Git.

## Temps et limites observés

Durées internes des appels MCP, hors temps de raisonnement et d'installation :

| Action | Durée |
| --- | ---: |
| Navigation vers l'espace de génération | 1,351 s |
| Ouverture de la lampe dans l'historique | 5,818 s |
| Recherche du bouton Exporter | 0,038 s |
| Ouverture réussie du menu Exporter | 6,110 s |

Deux clics normaux ont expiré (5 puis 15 secondes) pendant l'attente Playwright
de stabilité de l'élément. La visibilité et l'état activé ont été vérifiés, puis
un clic avec `force: true` a ouvert le menu. Cause exacte de cette attente non
démontrée : ne pas l'attribuer définitivement au chargement ou à l'arrière-plan.

Chrome a ensuite bien téléchargé le GLB, mais `page.waitForEvent('download')`
n'a pas signalé l'événement : attente expirée à 45 secondes. La présence réelle
du fichier dans Downloads et son contenu ont été vérifiés sur disque. Ce timeout
ne mesure donc pas la durée réelle de l'export Tripo.

**Conclusion :** accès structuré utile et nettement moins de captures/repérage
manuel ; automatisation complète rapide pas encore démontrée. Pour une reprise,
prévoir une détection du fichier exporté sur disque et diagnostiquer l'attente de
stabilité. Ne pas multiplier les clics Exporter pour compenser un événement absent.
Génération payante et retopologie volontairement non testées.

Sources : [serveur Microsoft](https://github.com/microsoft/playwright-mcp),
[extension officielle](https://github.com/microsoft/playwright/blob/main/packages/extension/README.md).

## Suite autorisée — usage P6A3 du même jour

Le test ci-dessus reste un témoin sans dépense. Antoine a ensuite explicitement
autorisé la mission complète et les crédits Studio. Voir le
[P6A3 Tool Feel report](P6A3_TOOL_FEEL_SENSORY_REPORT.md) pour la livraison réelle.
Les outils MCP sont maintenant exposés nativement dans la session Codex.

Leçons d'exécution : utiliser un onglet Codex distinct ; uploader les références
par `setInputFiles({name,mimeType,buffer})`, préparé localement par
`tools/p6a3/prepare_studio_upload.py`. Le chemin direct est refusé par l'extension
Chrome. Vérifier l'UUID, le vrai modèle sélectionné (high/retopo), le coût affiché
et la topologie avant soumission. Conserver un registre par job ; un timeout
n'autorise pas un nouvel achat automatique.

Les menus/historiques restent parfois lents ; utiliser des locators DOM observés,
limiter les attentes et vérifier les overlays avant les clics. Un modèle affiché
via l'historique peut différer de la version courante exportée : contrôler les
triangles du GLB téléchargé, pas seulement le nom du fichier.

L'événement download reste peu fiable. Vérifier le disque puis, si nécessaire,
récupérer le lien officiel d'export déjà observé dans le trafic Studio. Les liens
signés expirent rapidement et ne sont jamais versionnés. Le master Blower a été
conservé depuis le GLB officiel du viewer après expiration du lien convertisseur ;
son import Blender et ses triangles ont été vérifiés. Aucun appel privé de
soumission de tâches ni contournement de paiement n'a été ajouté.

L'usage Studio a consommé 395 crédits autorisés pour quatre générations et cinq
retopologies. Ces valeurs historiques ne constituent pas une autorisation de
nouvelles dépenses. Pour la prochaine action, lire le statut canonique.
