param([switch]$Windowed)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$candidates = @(
    $env:GODOT_EXE,
    (Join-Path $env:USERPROFILE 'Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe')
)
$godot = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $godot) {
    $command = Get-Command 'Godot_v4.7.2-stable_mono_win64.exe' -ErrorAction SilentlyContinue
    if ($command) { $godot = $command.Source }
}
if (-not $godot) { throw 'Godot 4.7.2 introuvable. Définissez GODOT_EXE vers son exécutable.' }
$gameArguments = @('--path', ('"' + $root + '"'), '--rendering-method', 'gl_compatibility')
if ($Windowed) { $gameArguments += @('--windowed', '--resolution', '1600x900') }
$gameArguments += 'res://scenes/collection/exhibit_workshop.tscn'
Start-Process -FilePath $godot -ArgumentList $gameArguments -WorkingDirectory $root
