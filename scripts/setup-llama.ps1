# setup-llama.ps1 - Download and extract prebuilt llama.cpp binaries for Jacky
# Target directory: %APPDATA%\Jacky\bin

$ErrorActionPreference = "Stop"

$binDir = Join-Path $env:APPDATA "Jacky\bin"
$modelsDir = Join-Path $env:APPDATA "Jacky\models"

if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}
if (-not (Test-Path $modelsDir)) {
    New-Item -ItemType Directory -Path $modelsDir -Force | Out-Null
}

$buildNumber = "b11146"
$cpuZipUrl = "https://github.com/ggml-org/llama.cpp/releases/download/$buildNumber/llama-$buildNumber-bin-win-cpu-x64.zip"
$zipTarget = Join-Path $env:TEMP "llama-$buildNumber-bin-win-cpu-x64.zip"

Write-Host "Target bin directory: $binDir"
Write-Host "Downloading llama.cpp $buildNumber (CPU x64 AVX2)..."

# Using curl.exe for high performance & reliable progress
& curl.exe -L --fail --output $zipTarget $cpuZipUrl

if (-not (Test-Path $zipTarget)) {
    throw "Failed to download $cpuZipUrl"
}

Write-Host "Extracting binaries into $binDir..."
Expand-Archive -Path $zipTarget -DestinationPath $binDir -Force

# Verify key executables exist
$serverExe = Join-Path $binDir "llama-server.exe"
$benchExe = Join-Path $binDir "llama-bench.exe"
$cliExe = Join-Path $binDir "llama-cli.exe"

if ((Test-Path $serverExe) -and (Test-Path $benchExe)) {
    Write-Host "[x] llama-server.exe and llama-bench.exe successfully installed at $binDir" -ForegroundColor Green
    & $serverExe --version
} else {
    Write-Warning "Could not find expected executables in $binDir. Checking extracted contents:"
    Get-ChildItem -Path $binDir
}
