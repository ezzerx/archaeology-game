param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical,
    [switch]$SkipRegression
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
if (-not $SkipRegression) {
    & (Join-Path $PSScriptRoot 'check_p4v.ps1') -GodotBin $enginePath -Graphical:$Graphical
}

function Invoke-P4V2Check([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $projectRoot "work/test-logs/$Name.log"
    if ('--headless' -notin $EngineArguments) { $EngineArguments += @('--position', '100,100') }
    & $enginePath @EngineArguments --path $projectRoot --log-file $logPath
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}

Invoke-P4V2Check 'p4v2-tests' @('--headless', '--script', 'res://tests/run_p4v2_tests.gd')
$first = Get-Content -LiteralPath (Join-Path $projectRoot 'work/test-logs/p4v2-tests.json') -Raw | ConvertFrom-Json
Invoke-P4V2Check 'p4v2-repeat' @('--headless', '--script', 'res://tests/run_p4v2_tests.gd')
$second = Get-Content -LiteralPath (Join-Path $projectRoot 'work/test-logs/p4v2-tests.json') -Raw | ConvertFrom-Json
if ($first.replay_sha256 -ne $second.replay_sha256) { throw 'V2 cross-process physics replay differs' }
Write-Output 'P4V2 cross-process replay: identical'
if ($Graphical) {
    Invoke-P4V2Check 'p4v2-benchmark' @('--script', 'res://tests/run_p4v2_benchmark.gd')
}
