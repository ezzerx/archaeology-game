param([string]$BlenderBin = $env:BLENDER_BIN)
$ErrorActionPreference = 'Stop'
if (-not $BlenderBin) {
    $BlenderBin = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe'
}
if (-not (Test-Path -LiteralPath $BlenderBin)) { throw 'Blender absent. Set BLENDER_BIN or pass -BlenderBin; see P6A2_PREFLIGHT_REPORT.md.' }
$version = & $BlenderBin --background --factory-startup --version
if ($LASTEXITCODE -ne 0 -or $version[0] -notmatch '^Blender 5\.2\.2 LTS') { throw "Expected Blender 5.2.2 LTS: $version" }
& $BlenderBin --background --factory-startup --python-exit-code 1 --python (Join-Path $PSScriptRoot 'create_probe.py')
if ($LASTEXITCODE -ne 0) { throw 'Blender probe export failed' }
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
& $BlenderBin --background --factory-startup (Join-Path $repoRoot 'art/source/preflight/pipeline_probe.blend') --python-exit-code 1 --python (Join-Path $PSScriptRoot 'export_static.py') -- --output (Join-Path $repoRoot 'assets/preflight/pipeline_probe.glb')
if ($LASTEXITCODE -ne 0) { throw 'Saved .blend to GLB export failed' }
