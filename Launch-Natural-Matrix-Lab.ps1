param([string]$GodotBin)
$ErrorActionPreference = 'Stop'
if (-not $GodotBin) {
    $localEngine = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe'
    if (Test-Path -LiteralPath $localEngine) { $GodotBin = $localEngine }
    else { throw 'Pass -GodotBin <Godot executable> or open scenes/p6a16_natural_matrix_lab.tscn and press F6.' }
}
& $GodotBin --path $PSScriptRoot res://scenes/p6a16_natural_matrix_lab.tscn
