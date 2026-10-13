"""Package the actual Godot export for static hosting; no gameplay simulation.
Usage: python3 tools/p6a31/package_web.py /absolute/export/directory
"""
import gzip, hashlib, json, sys
from pathlib import Path

out = Path(sys.argv[1])
manifest = {}
for name in ['index.wasm', 'index.pck']:
    raw = (out / name).read_bytes()
    compressed = gzip.compress(raw, compresslevel=6, mtime=0)
    parts = []
    for start in range(0, len(compressed), 8 * 1024 * 1024):
        part = f'{name}.gz.part{len(parts):02d}'
        (out / part).write_bytes(compressed[start:start + 8 * 1024 * 1024])
        parts.append(part)
    manifest[name] = {'parts': parts, 'size': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(), 'mime': 'application/wasm' if name.endswith('.wasm') else 'application/octet-stream'}
    (out / name).unlink()
(out / 'payload.json').write_text(json.dumps(manifest))
# Only asset transport changes. The engine sees the original verified bytes.
(out / 'transport.js').write_text('''const originalFetch = window.fetch.bind(window);
let payloadManifest;
window.fetch = async (resource, options) => {
  const url = new URL(resource instanceof Request ? resource.url : resource, location.href);
  const name = url.pathname.split('/').pop();
  if (url.origin !== location.origin || !['index.wasm', 'index.pck'].includes(name)) return originalFetch(resource, options);
  payloadManifest ??= originalFetch('payload.json').then(r => { if (!r.ok) throw Error('Chargement indisponible'); return r.json(); });
  const entry = (await payloadManifest)[name];
  const parts = await Promise.all(entry.parts.map(async part => {
    const response = await originalFetch(part);
    if (!response.ok) throw Error('Un fichier du jeu est indisponible. Réessaie le chargement.');
    return response.arrayBuffer();
  }));
  const stream = new Blob(parts).stream().pipeThrough(new DecompressionStream('gzip'));
  const bytes = await new Response(stream).arrayBuffer();
  if (bytes.byteLength !== entry.size) throw Error('Chargement incomplet. Réessaie.');
  const digest = [...new Uint8Array(await crypto.subtle.digest('SHA-256', bytes))].map(v => v.toString(16).padStart(2,'0')).join('');
  if (digest !== entry.sha256) throw Error('Le fichier reçu ne correspond pas à cette version du jeu.');
  return new Response(bytes, {headers: {'Content-Type': entry.mime, 'Content-Length': String(entry.size)}});
};
''')
config = {'args': [], 'canvasResizePolicy': 2, 'executable': 'index', 'fileSizes': {n: e['size'] for n, e in manifest.items()}, 'focusCanvas': True, 'gdextensionLibs': [], 'ensureCrossOriginIsolationHeaders': False}
(out / 'index.html').write_text('''<!doctype html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>ArchaeologyGame · Playtest privé</title><link rel="icon" href="index.icon.png">
<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#211c16;color:#f2e6ce;font-family:system-ui,sans-serif}canvas{display:block;width:100%;height:100%;outline:none}#welcome{position:fixed;inset:0;display:grid;place-items:center;background:radial-gradient(ellipse at top,#493a26,#211c16)}article{width:min(520px,90vw);padding:36px;border:1px solid #8e7856;background:#f2e6ce;color:#463c2c;box-shadow:0 18px 70px #0005}h1{font:normal 34px Georgia,serif;margin:12px 0 16px}.eyebrow{font-size:11px;letter-spacing:.15em;text-transform:uppercase;color:#7b6c54}p{line-height:1.6;font-size:15px}button{width:100%;padding:14px;border:0;background:#54684e;color:#fff8e8;font:600 16px system-ui;cursor:pointer}button:disabled{opacity:.65;cursor:wait}button:focus-visible{outline:3px solid #997035;outline-offset:4px}#status{font-size:14px;min-height:24px;margin-top:18px}progress{width:100%;height:7px;accent-color:#54684e}.hint{font-size:12px;color:#7b6c54}
</style></head><body><canvas id="canvas" tabindex="0" aria-label="Atelier de préparation du fossile B-17"></canvas>
<div id="welcome"><article><div class="eyebrow">Musée d’histoire naturelle · atelier</div><h1>Prépare le spécimen B-17.</h1><p>Un bloc, quatre outils, un fossile à révéler et à nettoyer. Prends ton temps.</p><p class="hint">Clic gauche : travailler · 1–4 : outils<br>Molette : zoom · Clic droit glissé : déplacer la vue<br>R : recommencer · Home : vue d’ensemble</p><button id="start">Lancer le playtest</button><div id="status" role="status" aria-live="polite">Version de test P6A3.1 · accès privé</div><progress id="progress" hidden></progress><p class="hint">Le premier chargement peut prendre un moment. À tester sur ordinateur, avec une souris et le son activé.</p><noscript>Active JavaScript pour jouer.</noscript></article></div>
<script src="transport.js"></script><script src="index.js"></script><script>
const config = ''' + json.dumps(config) + ''';
const engine = new Engine(config);
const button = document.getElementById('start');
const status = document.getElementById('status');
const progress = document.getElementById('progress');
button.onclick = async () => {
  button.disabled = true;
  status.textContent = 'Chargement du jeu…';
  progress.hidden = false;
  try {
    const missing = Engine.getMissingFeatures({threads:false});
    if (missing.length) throw Error('Ce navigateur ne peut pas lancer le jeu : '+missing.join(', '));
    await engine.startGame({canvas:document.getElementById('canvas'),onProgress:(current,total)=>{
      if (total>0) {progress.max=total;progress.value=current;} else {progress.removeAttribute('value');}
    }});
    document.getElementById('welcome').remove();
    document.getElementById('canvas').focus();
    window.playtestStarted = true;
  } catch(error) {
    status.textContent = error.message || 'Le jeu n’a pas pu démarrer. Réessaie.';
    button.textContent = 'Réessayer';button.disabled = false;progress.hidden = true;
    console.error(error);
  }
};
</script></body></html>
''')
print(json.dumps({'files': manifest, 'download_bytes': sum((out/p).stat().st_size for e in manifest.values() for p in e['parts'])}, indent=2))
