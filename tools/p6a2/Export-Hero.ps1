param([string]$BlenderBin = $env:BLENDER_BIN, [switch]$Regenerate)
$ErrorActionPreference = 'Stop'
if (-not $BlenderBin) {
    $BlenderBin = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe'
}
if (-not (Test-Path -LiteralPath $BlenderBin)) { throw 'Set BLENDER_BIN or pass -BlenderBin; see P6A2_PREFLIGHT_REPORT.md.' }
$version = & $BlenderBin --background --factory-startup --version
if ($LASTEXITCODE -ne 0 -or $version[0] -notmatch '^Blender 5\.2\.2 LTS') { throw "Expected Blender 5.2.2 LTS: $version" }
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if ($Regenerate) {
    # Explicit opt-in: replaces the authored .blend and four data plates.
    & $BlenderBin --background --factory-startup --python-exit-code 1 --python (Join-Path $PSScriptRoot 'build_hero_assets.py')
    if ($LASTEXITCODE -ne 0) { throw 'Hero source generation failed' }
}
$source = Join-Path $repoRoot 'art/source/p6a2/meshes/b17_jacket.blend'
$output = Join-Path $repoRoot 'assets/p6a2/static/b17_jacket.glb'
& $BlenderBin --background --factory-startup $source --python-exit-code 1 --python (Join-Path $repoRoot 'tools/preflight/export_static.py') -- --output $output
if ($LASTEXITCODE -ne 0) { throw 'Saved Hero .blend to GLB export failed' }
Get-FileHash -LiteralPath $output -Algorithm SHA256
