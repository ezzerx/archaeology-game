param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
$logDirectory = Join-Path $projectRoot 'work/test-logs'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
Set-Content -LiteralPath (Join-Path $projectRoot 'work/.gdignore') -Value '' -Encoding utf8
$engineVersion = & $enginePath --version
if ($engineVersion -notmatch '^4\.7\.2\.stable') {
    throw "Expected Godot 4.7.2 stable; received $engineVersion"
}
Write-Output $engineVersion

function Invoke-Check([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $logDirectory "$Name.log"
    & $enginePath @EngineArguments --path $projectRoot --log-file $logPath
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    # Godot can return zero after some parser/import errors. Inspect its log too.
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}

Invoke-Check 'p1-import' @('--headless', '--editor', '--import')
Invoke-Check 'p0-regression' @('--headless', '--script', 'res://tests/run_tests.gd')
Invoke-Check 'p1-tests' @('--headless', '--script', 'res://tests/run_p1_tests.gd')
Invoke-Check 'p1-scene' @('--headless', '--quit-after', '120')
if ($Graphical) {
    Invoke-Check 'p1-benchmark' @('--script', 'res://tests/run_graphical_benchmark.gd')
}
