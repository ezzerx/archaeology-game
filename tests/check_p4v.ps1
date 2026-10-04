param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
& (Join-Path $PSScriptRoot 'check_p4.ps1') -GodotBin $enginePath -Graphical:$Graphical

function Invoke-P4VCheck([string]$Name, [string[]]$EngineArguments) {
    $logPath = Join-Path $projectRoot "work/test-logs/$Name.log"
    if ('--headless' -notin $EngineArguments) { $EngineArguments += @('--position', '100,100') }
    & $enginePath @EngineArguments --path $projectRoot --log-file $logPath
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "$Name contains an error; inspect $logPath"
    }
    Write-Output "$Name`: PASS"
}

Invoke-P4VCheck 'p4v-tests' @('--headless', '--script', 'res://tests/run_p4v_tests.gd')
$first = Get-Content -LiteralPath (Join-Path $projectRoot 'work/test-logs/p4v-tests.json') -Raw | ConvertFrom-Json
Invoke-P4VCheck 'p4v-repeat' @('--headless', '--script', 'res://tests/run_p4v_tests.gd')
$second = Get-Content -LiteralPath (Join-Path $projectRoot 'work/test-logs/p4v-tests.json') -Raw | ConvertFrom-Json
foreach ($size in @('(1024, 640)', '(512, 320)', '(256, 160)')) {
    foreach ($field in @('layers_sha256', 'fossil_sha256', 'ids_sha256')) {
        if ($first.$size.$field -ne $second.$size.$field) { throw "Cross-process determinism failed: $size / $field" }
    }
}
Write-Output 'P4V cross-process determinism: 9 hashes identical'
Invoke-P4VCheck 'p4v-effort-tests' @('--headless', '--script', 'res://tests/run_p4v_effort_tests.gd')
if ($Graphical) {
    Invoke-P4VCheck 'p4v-benchmark' @('--script', 'res://tests/run_p4v_benchmark.gd')
}
