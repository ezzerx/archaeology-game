param([string]$GodotBin, [string]$BlenderBin, [switch]$Graphical)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $GodotBin) { $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe' }
if (-not $BlenderBin) { $BlenderBin = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe' }
if (-not (Test-Path -LiteralPath $GodotBin)) { throw 'Pass -GodotBin for Godot 4.7.2 stable.' }
if (-not (Test-Path -LiteralPath $BlenderBin)) { throw 'Pass -BlenderBin for Blender 5.2.2 LTS.' }
$engineVersion = & $GodotBin --version
if ($engineVersion -notlike '4.7.2.stable*') { throw 'Godot 4.7.2 stable required.' }
$blenderVersion = & $BlenderBin --version
if ($blenderVersion[0] -ne 'Blender 5.2.2 LTS') { throw 'Blender 5.2.2 LTS required.' }
& $BlenderBin --background --threads 4 --python-exit-code 1 --python (Join-Path $PSScriptRoot 'build_skeleton.py')
if ($LASTEXITCODE -ne 0) { throw 'Mesh build failed.' }
& $GodotBin --headless --editor --path $repoRoot --quit
if ($LASTEXITCODE -ne 0) { throw 'Mesh import failed.' }
& $GodotBin --headless --path $repoRoot --script res://tools/p6a37/pack_field.gd
if ($LASTEXITCODE -ne 0) { throw 'Field packing failed.' }
& $GodotBin --headless --path $repoRoot --script res://tests/run_p6a37_skeleton.gd -- tests --distinction-store=res://work/test-logs/p6a37/collection-test.json
if ($LASTEXITCODE -ne 0) { throw 'Pilot tests failed.' }
if ($Graphical) {
    & $GodotBin --path $repoRoot --script res://tests/run_p6a37_skeleton.gd -- visual --distinction-store=res://work/test-logs/p6a37/collection-test.json
    if ($LASTEXITCODE -ne 0) { throw 'Pilot graphical checks failed.' }
}
