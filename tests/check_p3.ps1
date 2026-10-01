param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
& (Join-Path $PSScriptRoot 'check_p2.ps1') -GodotBin $enginePath -Graphical:$Graphical

function Invoke-P3Check([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $projectRoot "work/test-logs/$Name.log"
    & $enginePath @EngineArguments --path $projectRoot --log-file $logPath
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}

Invoke-P3Check 'p3-tests' @('--headless', '--script', 'res://tests/run_p3_tests.gd')
Invoke-P3Check 'p3-zoom-tests' @('--headless', '--script', 'res://tests/run_p3_zoom_tests.gd')
if ($Graphical) {
    Invoke-P3Check 'p1-on-p3-benchmark' @('--script', 'res://tests/run_graphical_benchmark.gd')
    Invoke-P3Check 'p3-benchmark' @('--script', 'res://tests/run_p3_benchmark.gd')
}
