param([string]$GodotBin, [string]$BlenderBin)
$ErrorActionPreference = 'Stop'
$taskProject = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
if (-not $GodotBin) { $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe' }
if (-not $BlenderBin) { $BlenderBin = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/blender-5.2.2-windows-x64/blender.exe' }
$taskEngineVersion = & $GodotBin --version
if ($LASTEXITCODE -ne 0 -or $taskEngineVersion -notmatch '^4\.7\.2\.stable') { throw 'Godot 4.7.2 stable required.' }
& $BlenderBin --background --threads 4 --python-exit-code 1 --python (Join-Path $PSScriptRoot 'build_ammonite.py')
if ($LASTEXITCODE -ne 0) { throw 'Blender source build failed.' }
& $GodotBin --headless --path $taskProject --editor --import
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
& $GodotBin --headless --path $taskProject --script 'tools/p6a50/pack_field.gd'
if ($LASTEXITCODE -ne 0) { throw 'Field pack failed.' }
