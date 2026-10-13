param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical,
    [switch]$Benchmark,
    [switch]$Regression
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'work/test-logs/p6a15') | Out-Null
function Invoke-Soil([string]$Mode, [switch]$Headless) {
    $logPath = Join-Path $projectRoot "work/test-logs/p6a15-$Mode.log"
    $engineArgs = @('--path', $projectRoot, '--log-file', $logPath)
    if ($Headless) { $engineArgs += '--headless' }
    $engineArgs += @('--script', 'res://tests/run_p6a15_soil.gd', '--', $Mode)
    & $enginePath @engineArgs
    if ($LASTEXITCODE -ne 0) { throw "P6A15 $Mode failed: $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "P6A15 $Mode contains an error; inspect $logPath"
    }
}
Invoke-Soil 'tests' -Headless
if ($Regression) { & (Join-Path $PSScriptRoot 'check_p6a.ps1') -GodotBin $enginePath -Regression }
if ($Graphical) { Invoke-Soil 'visual' }
if ($Benchmark) { Invoke-Soil 'benchmark' }
