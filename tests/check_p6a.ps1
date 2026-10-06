param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical,
    [switch]$Benchmark,
    [switch]$Regression
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'work/test-logs/p6a') | Out-Null
function Invoke-Lab([string]$Mode, [switch]$Headless) {
    $logPath = Join-Path $projectRoot "work/test-logs/p6a-$Mode.log"
    $engineArgs = @('--path', $projectRoot, '--log-file', $logPath)
    if ($Headless) { $engineArgs += '--headless' }
    $engineArgs += @('--script', 'res://tests/run_p6a_lab.gd', '--', $Mode)
    & $enginePath @engineArgs
    if ($LASTEXITCODE -ne 0) { throw "P6A $Mode failed: $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "P6A ${Mode}: inspect $logPath"
    }
}
Invoke-Lab 'tests' -Headless
if ($Regression) { & (Join-Path $PSScriptRoot 'check_p5.ps1') -GodotBin $enginePath }
if ($Graphical) { Invoke-Lab 'visual' }
if ($Benchmark) { Invoke-Lab 'benchmark' }
