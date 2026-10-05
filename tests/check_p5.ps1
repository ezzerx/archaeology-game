param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical,
    [switch]$SkipRegression
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
if (-not $SkipRegression) {
    & (Join-Path $PSScriptRoot 'check_p4v2.ps1') -GodotBin $enginePath
}
function Invoke-P5Check([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $projectRoot "work/test-logs/$Name.log"
    & $enginePath --path $projectRoot --log-file $logPath @EngineArguments
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}
Invoke-P5Check 'p5-tests' @('--headless', '--script', 'res://tests/run_p5_tests.gd')
Invoke-P5Check 'p5c-tests' @('--headless', '--script', 'res://tests/run_p5_correction_tests.gd')
if ($Graphical) {
    Invoke-P5Check 'p5-visual' @('--position', '0,0', '--script', 'res://tests/run_p5_visual.gd')
    Invoke-P5Check 'p5-benchmark' @('--position', '0,0', '--script', 'res://tests/run_p5_benchmark.gd')
}
