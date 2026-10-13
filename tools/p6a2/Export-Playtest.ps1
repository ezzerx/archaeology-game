param([string]$GodotBin, [string]$TemplateDirectory)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $GodotBin) {
    $GodotBin = Join-Path $env:USERPROFILE 'Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
}
if (-not $TemplateDirectory) {
    $TemplateDirectory = Join-Path $env:LOCALAPPDATA 'Programs/ArchaeologyGameTools/godot-4.7.2-export'
}
if (-not (Test-Path -LiteralPath $GodotBin)) { throw 'Pass -GodotBin for Godot 4.7.2.' }
$version = & $GodotBin --version
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.7\.2\.stable') { throw "Wrong engine: $version" }
$template = Join-Path $TemplateDirectory 'windows_release_x86_64.exe'
if (-not (Test-Path -LiteralPath $template)) { throw 'Official Windows 4.7.2 template required; see playtest report.' }
if ((Get-Content (Join-Path $TemplateDirectory 'version.txt') -Raw).Trim() -ne '4.7.2.stable') { throw 'Wrong export template version.' }
# A fresh staging project avoids touching the active project or editor settings.
$stage = Join-Path $repoRoot ('builds/staging-p6a2-' + [Guid]::NewGuid().ToString('N'))
$output = Join-Path $repoRoot 'builds/P6A2-Playtest'
New-Item -ItemType Directory -Force -Path $stage,$output | Out-Null
foreach ($folder in @('scripts','scenes','config','shaders','materials','assets')) {
    Copy-Item -LiteralPath (Join-Path $repoRoot $folder) -Destination $stage -Recurse
}
$project = [System.IO.File]::ReadAllText((Join-Path $repoRoot 'project.godot'))
$project = $project.Replace('res://scenes/prototype_main.tscn','res://scenes/p6a2_hero_patch.tscn')
$project = $project.Replace('config/name="ArchaeologyGame — P4"','config/name="ArchaeologyGame Playtest"')
[System.IO.File]::WriteAllText((Join-Path $stage 'project.godot'),$project,[System.Text.UTF8Encoding]::new($false))
$templatePath = $template.Replace('\','/')
$preset = @"
[preset.0]
name="Windows Playtest"
platform="Windows Desktop"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter="*.gdshaderinc"
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.0.options]
custom_template/debug=""
custom_template/release="$templatePath"
debug/export_console_wrapper=0
binary_format/embed_pck=false
binary_format/architecture="x86_64"
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
codesign/enable=false
application/modify_resources=false
"@
[System.IO.File]::WriteAllText((Join-Path $stage 'export_presets.cfg'),$preset,[System.Text.UTF8Encoding]::new($false))
& $GodotBin --headless --path $stage --editor --quit *> (Join-Path $output 'import.log')
if ($LASTEXITCODE -ne 0) { throw 'Staging import failed; see builds/P6A2-Playtest/import.log' }
$exe = Join-Path $output 'ArchaeologyGame.exe'
& $GodotBin --headless --path $stage --export-release 'Windows Playtest' $exe *> (Join-Path $output 'export.log')
if ($LASTEXITCODE -ne 0) { throw 'Windows export failed; see builds/P6A2-Playtest/export.log' }
& $GodotBin --headless --path $repoRoot --script tools/p6a2/export_notices.gd -- $output
if ($LASTEXITCODE -ne 0) { throw 'Export notices failed' }
Copy-Item -LiteralPath (Join-Path $repoRoot 'docs/dev/P6A2_PLAYTEST_README.txt') -Destination (Join-Path $output 'LISEZ-MOI.txt')
$files = @('ArchaeologyGame.exe','ArchaeologyGame.pck','LISEZ-MOI.txt','LICENCES.txt') | ForEach-Object { Join-Path $output $_ }
$zip = Join-Path $repoRoot 'builds/ArchaeologyGame-P6A2-Playtest-Windows.zip'
Compress-Archive -LiteralPath $files -DestinationPath $zip -Force
Get-FileHash -LiteralPath ($files + @($zip)) -Algorithm SHA256
Write-Output "Playtest: $exe"
Write-Output "Portable ZIP: $zip"
