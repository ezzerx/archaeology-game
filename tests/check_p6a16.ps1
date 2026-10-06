param(
    [Parameter(Mandatory = $true)][string]$GodotBin,
    [switch]$Graphical,
    [switch]$Benchmark,
    [switch]$Regression
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$enginePath = (Resolve-Path -LiteralPath $GodotBin).Path
New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'work/test-logs/p6a16-structured') | Out-Null
function Invoke-Matrix([string]$Mode, [switch]$Headless) {
    $logPath = Join-Path $projectRoot "work/test-logs/p6a16-structured-$Mode.log"
    $engineArgs = @('--path', $projectRoot, '--log-file', $logPath)
    if ($Headless) { $engineArgs += '--headless' }
    $engineArgs += @('--script', 'res://tests/run_p6a16_geometry.gd', '--', $Mode)
    & $enginePath @engineArgs
    if ($LASTEXITCODE -ne 0) { throw "P6A16 $Mode failed: $LASTEXITCODE" }
    if (Select-String -LiteralPath $logPath -Pattern 'SCRIPT ERROR|ERROR:|Parse Error|SHADER ERROR' -Quiet) {
        throw "P6A16 ${Mode}: inspect $logPath"
    }
}
Invoke-Matrix 'tests' -Headless
if ($Regression) { & (Join-Path $PSScriptRoot 'check_p6a15.ps1') -GodotBin $enginePath -Regression -Graphical }
if ($Graphical) { Invoke-Matrix 'visual' }
if ($Benchmark) { Invoke-Matrix 'benchmark' }
