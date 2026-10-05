# download-models.ps1 - Download verified GGUF models for Jacky benchmarks
# FAST: Qwen2.5-1.5B-Instruct Q4_K_M (~986 MB)
# DEEP: Phi-4-mini-Instruct Q4_K_M (~2.49 GB)

$ErrorActionPreference = "Stop"

$modelsDir = Join-Path $env:APPDATA "Jacky\models"
if (-not (Test-Path $modelsDir)) {
    New-Item -ItemType Directory -Path $modelsDir -Force | Out-Null
}

$fastUrl = "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf"
$fastTarget = Join-Path $modelsDir "qwen2.5-1.5b-instruct-q4_k_m.gguf"

if (-not (Test-Path $fastTarget)) {
    Write-Host "Downloading FAST Model (Qwen2.5-1.5B-Instruct Q4_K_M, ~986 MB)..."
    & curl.exe -L --fail --output $fastTarget $fastUrl
    Write-Host "[x] FAST model downloaded to $fastTarget" -ForegroundColor Green
} else {
    Write-Host "[x] FAST model already exists at $fastTarget" -ForegroundColor Green
}

$deepUrl = "https://huggingface.co/bartowski/microsoft_Phi-4-mini-instruct-GGUF/resolve/main/microsoft_Phi-4-mini-instruct-Q4_K_M.gguf"
$deepTarget = Join-Path $modelsDir "phi-4-mini-instruct-q4_k_m.gguf"

if (-not (Test-Path $deepTarget)) {
    Write-Host "Downloading DEEP Model (Phi-4-mini-Instruct Q4_K_M, ~2.49 GB)..."
    & curl.exe -L --fail --output $deepTarget $deepUrl
    Write-Host "[x] DEEP model downloaded to $deepTarget" -ForegroundColor Green
} else {
    Write-Host "[x] DEEP model already exists at $deepTarget" -ForegroundColor Green
}

Get-ChildItem -Path $modelsDir
