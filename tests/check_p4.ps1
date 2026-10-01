param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
& (Join-Path $PSScriptRoot 'check_p3.ps1') -GodotBin $enginePath

function Invoke-P4Check([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $projectRoot "work/test-logs/$Name.log"
    & $enginePath @EngineArguments --path $projectRoot --log-file $logPath
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}

Invoke-P4Check 'p4-tests' @('--headless', '--script', 'res://tests/run_p4_tests.gd')
Invoke-P4Check 'p4-condition' @('--headless', '--script', 'res://tests/run_p4_condition_probe.gd')
if ($Graphical) {
    Invoke-P4Check 'p4-benchmark' @('--script', 'res://tests/run_p4_benchmark.gd')
    Invoke-P4Check 'p3-on-p4-gpu' @('--script', 'res://tests/run_p3_benchmark.gd', '--', '--gpu-only')
}
