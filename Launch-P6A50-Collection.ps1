param([string]$GodotBin)
$ErrorActionPreference = 'Stop'
if (-not $GodotBin) {
    $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $GodotBin)) { throw 'Pass -GodotBin for Godot 4.7.2 stable.' }
$taskEngineVersion = & $GodotBin --version
if ($LASTEXITCODE -ne 0 -or $taskEngineVersion -notmatch '^4\.7\.2\.stable') { throw 'Godot 4.7.2 stable required.' }
& $GodotBin --path $PSScriptRoot res://scenes/p6a50_collection_loop.tscn
exit $LASTEXITCODE
