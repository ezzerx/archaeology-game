param([string]$GodotBin, [switch]$InspectSkull)
$ErrorActionPreference = 'Stop'
if (-not $GodotBin) {
    $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $GodotBin)) { throw 'Pass -GodotBin for Godot 4.7.2.' }
$taskGodotArguments = @('--path', $PSScriptRoot, 'res://scenes/p6a36_hero_skull.tscn')
if ($InspectSkull) { $taskGodotArguments += @('--', '--inspect-skull') }
& $GodotBin @taskGodotArguments
