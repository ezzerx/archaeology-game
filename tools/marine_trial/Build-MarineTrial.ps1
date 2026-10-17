param([string]$GodotBin, [string]$BlenderBin)
$ErrorActionPreference = 'Stop'
$marineProject = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
if (-not $GodotBin) { $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe' }
if (-not $BlenderBin) { $BlenderBin = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe' }
& $BlenderBin --background --threads 4 --python-exit-code 1 --python (Join-Path $PSScriptRoot 'build_layout.py')
if ($LASTEXITCODE -ne 0) { throw 'Marine layout build failed.' }
& $GodotBin --headless --path $marineProject --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Marine model import failed.' }
& $GodotBin --headless --path $marineProject --script res://tools/marine_trial/pack_field.gd
if ($LASTEXITCODE -ne 0) { throw 'Marine contact field pack failed.' }
