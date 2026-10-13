param([string]$GodotBin)
$ErrorActionPreference = 'Stop'
if (-not $GodotBin) {
    $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe'
}
if (-not (Test-Path -LiteralPath $GodotBin)) { throw 'Pass -GodotBin <Godot 4.7.2>, or open scenes/p6a2_hero_patch.tscn and press F6.' }
& $GodotBin --path $PSScriptRoot res://scenes/p6a2_hero_patch.tscn
