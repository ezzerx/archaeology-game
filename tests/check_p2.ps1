param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
& (Join-Path $PSScriptRoot 'check_p1.ps1') -GodotBin $enginePath

function Invoke-P2Check([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $projectRoot "work/test-logs/$Name.log"
    & $enginePath @EngineArguments --path $projectRoot --log-file $logPath
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}

Invoke-P2Check 'p2-tests' @('--headless', '--script', 'res://tests/run_p2_tests.gd')
if ($Graphical) {
    Invoke-P2Check 'p2-benchmark' @('--script', 'res://tests/run_p2_benchmark.gd')
}
